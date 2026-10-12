import { test } from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { once } from 'node:events';
import { createAnalysisServer, analyzeImage, validateImage, MAX_IMAGE_BYTES, MAX_BODY_BYTES } from './server.mjs';

// Synthetic one-pixel PNG only. No user's photos, credentials, or live paid API calls.
const image = { mimeType: 'image/png', imageBase64: 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aD1cAAAAASUVORK5CYII=' };
const estimate = { status: 'estimated', foods: [{ name: 'Rice', portion: 'About 1 cup', calories: 205 }], uncertaintyNote: 'Portion size and hidden oil are uncertain.' };
const upstream = (value = estimate) => new Response(JSON.stringify({ status: 'completed', output: [{ type: 'message', content: [{ type: 'output_text', text: JSON.stringify(value) }] }] }), { status: 200 });
const settings = { apiKey: 'test-placeholder-not-a-key', model: 'test-vision-model' };

async function withServer(t, options = {}) {
  const server = createAnalysisServer({ ...settings, fetchImpl: async () => upstream(), ...options });
  server.listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(() => new Promise(resolve => { server.closeAllConnections(); server.close(resolve); }));
  const url = `http://127.0.0.1:${server.address().port}`;
  const post = (body = image, headers = {}) => fetch(`${url}/analyze`, { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: typeof body === 'string' ? body : JSON.stringify(body) });
  return { url, post, server };
}
const expectError = async (response, status, code) => {
  assert.equal(response.status, status);
  const body = await response.json();
  assert.equal(body.error.code, code);
  assert.deepEqual(Object.keys(body), ['error']);
};

test('real HTTP request constructs Responses image input and strict schema; returns reviewable estimate', async t => {
  let calls = 0;
  const { post } = await withServer(t, { fetchImpl: async (url, options) => {
    calls++;
    assert.equal(url, 'https://api.openai.com/v1/responses');
    assert.equal(options.redirect, 'error');
    const body = JSON.parse(options.body);
    assert.equal(body.store, false);
    assert.equal(body.model, settings.model);
    assert.equal(body.text.format.type, 'json_schema');
    assert.equal(body.text.format.strict, true);
    assert.equal(body.text.format.schema.additionalProperties, false);
    assert.equal(body.input[0].content[1].type, 'input_image');
    assert.equal(body.input[0].content[1].image_url, `data:image/png;base64,${image.imageBase64}`);
    return upstream();
  } });
  const response = await post();
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  const body = await response.json();
  assert.deepEqual(body.foods, estimate.foods);
  assert.equal(body.source, 'openai');
  assert.equal(body.isEstimate, true);
  assert.match(body.uncertaintyNote, /Not medical advice/);
  assert.equal(calls, 1);
});

test('health is configuration-free and does not call upstream', async t => {
  const { url } = await withServer(t, { fetchImpl: () => assert.fail('must not call upstream') });
  const response = await fetch(`${url}/health`);
  assert.deepEqual(await response.json(), { status: 'ok' });
});

test('unconfigured server has explicit blocker and makes no upstream call', async t => {
  const { post } = await withServer(t, { apiKey: '', model: '', fetchImpl: () => assert.fail('must not call upstream') });
  await expectError(await post(), 503, 'not_configured');
});

for (const status of ['no_food', 'uncertain']) {
  test(`rejects ${status} instead of inventing food`, async t => {
    const { post } = await withServer(t, { fetchImpl: async () => upstream({ ...estimate, status, foods: [] }) });
    await expectError(await post(), 422, status);
  });
}

test('rejects invalid JSON, schema, type, signature, and base64 before sending data', async t => {
  const { post } = await withServer(t, { fetchImpl: () => assert.fail('must not call upstream'), maxRequestsPerMinute: 100 });
  for (const [body, status, code] of [
    ['{', 400, 'invalid_json'], [{ ...image, extra: true }, 400, 'invalid_request'],
    [{ ...image, mimeType: 'image/svg+xml' }, 415, 'unsupported_image'],
    [{ ...image, mimeType: 'image/jpeg' }, 400, 'invalid_image'],
    [{ ...image, imageBase64: 'data:image/png;base64,abcd' }, 400, 'invalid_image'],
    [{ ...image, imageBase64: '!!!!' }, 400, 'invalid_image'],
    [{ ...image, imageBase64: 'AB==' }, 400, 'invalid_image'],
    [null, 400, 'invalid_request'],
  ]) await expectError(await post(body), status, code);
});

test('validates JPEG and WebP signatures and bounds without decoder dependencies', () => {
  const jpeg = Buffer.from([0xff, 0xd8, 0xff, 0xe0, 0xff, 0xd9]);
  assert.equal(validateImage({ mimeType: 'image/jpeg', imageBase64: jpeg.toString('base64') }).mimeType, 'image/jpeg');
  const webp = Buffer.alloc(20); webp.write('RIFF'); webp.writeUInt32LE(12, 4); webp.write('WEBP', 8);
  assert.equal(validateImage({ mimeType: 'image/webp', imageBase64: webp.toString('base64') }).mimeType, 'image/webp');
  assert.throws(() => validateImage({ ...image, imageBase64: Buffer.alloc(MAX_IMAGE_BYTES + 1).toString('base64') }), { code: 'image_size' });
});

test('bounds actual HTTP body, content type, encoding and declared length', async t => {
  const { post, url } = await withServer(t);
  await expectError(await post(image, { 'Content-Type': 'text/plain' }), 415, 'unsupported_content_type');
  await expectError(await post(image, { 'Content-Encoding': 'gzip' }), 415, 'unsupported_content_type');
  await expectError(await post(' '.repeat(MAX_BODY_BYTES + 1)), 413, 'body_too_large');
  // Chunked input has no Content-Length: prove streaming cap is enforced too.
  const result = await new Promise((resolve, reject) => {
    const req = http.request(`${url}/analyze`, { method: 'POST', headers: { 'Content-Type': 'application/json' } }, res => {
      const chunks = []; res.on('data', chunk => chunks.push(chunk)); res.on('end', () => resolve({ status: res.statusCode, body: JSON.parse(Buffer.concat(chunks)) }));
    });
    req.on('error', reject);
    for (let i = 0; i < Math.ceil((MAX_BODY_BYTES + 1) / 65536); i++) req.write(Buffer.alloc(65536, 32));
    req.end();
  });
  assert.equal(result.status, 413); assert.equal(result.body.error.code, 'body_too_large');
});

test('does not accept browser origins, DNS-rebinding hostnames, or unsupported routes', async t => {
  const { post, url } = await withServer(t);
  await expectError(await post(image, { Origin: 'https://attacker.example' }), 403, 'forbidden');
  const rebound = await new Promise((resolve, reject) => {
    const req = http.get(`${url}/health`, { headers: { Host: 'attacker.example' } }, res => {
      res.resume(); res.on('end', () => resolve(res.statusCode));
    });
    req.on('error', reject);
  });
  assert.equal(rebound, 403);
  await expectError(await fetch(`${url}/analyze`), 405, 'method_not_allowed');
  await expectError(await fetch(`${url}/missing`), 404, 'not_found');
});

for (const [label, result, code] of [
  ['refusal', { status: 'completed', output: [{ type: 'message', content: [{ type: 'refusal', refusal: 'no' }] }] }, 'uncertain'],
  ['incomplete', { status: 'incomplete', output: [] }, 'incomplete_response'],
  ['missing output', { status: 'completed', output: [] }, 'invalid_response'],
]) test(`handles ${label}`, async t => {
  const { post } = await withServer(t, { fetchImpl: async () => new Response(JSON.stringify(result)) });
  await expectError(await post(), code === 'uncertain' ? 422 : 502, code);
});

for (const [label, invalid] of [
  ['empty foods', { ...estimate, foods: [] }],
  ['meal total over 50000', { ...estimate, foods: Array.from({ length: 6 }, () => ({ ...estimate.foods[0], calories: 10000 })) }],
  ['negative calories', { ...estimate, foods: [{ ...estimate.foods[0], calories: -1 }] }],
  ['fractional calories', { ...estimate, foods: [{ ...estimate.foods[0], calories: 1.2 }] }],
  ['unbounded calories', { ...estimate, foods: [{ ...estimate.foods[0], calories: 10001 }] }],
  ['extra field', { ...estimate, privateValue: 'not returned' }],
  ['blank name', { ...estimate, foods: [{ ...estimate.foods[0], name: ' ' }] }],
]) test(`rejects model output with ${label}`, async t => {
  const { post } = await withServer(t, { fetchImpl: async () => upstream(invalid) });
  await expectError(await post(), 502, 'invalid_response');
});

test('upstream HTTP errors never expose upstream details', async t => {
  const { post } = await withServer(t, { fetchImpl: async () => new Response('secret-sensitive-upstream-body', { status: 401 }) });
  const response = await post();
  assert.equal(response.status, 502);
  assert.doesNotMatch(await response.text(), /secret|sensitive/);
});

test('oversized upstream response is rejected', async t => {
  const { post } = await withServer(t, { fetchImpl: async () => new Response(' '.repeat(128 * 1024 + 1)) });
  await expectError(await post(), 502, 'invalid_response');
});

test('timeout is bounded and returned safely', async t => {
  const { post } = await withServer(t, { timeoutMs: 15, fetchImpl: (_url, { signal }) => new Promise((_resolve, reject) => signal.addEventListener('abort', () => reject(signal.reason), { once: true })) });
  await expectError(await post(), 504, 'timeout');
});

test('cancellation aborts upstream; does not silently retry', async () => {
  const controller = new AbortController();
  let calls = 0;
  const pending = analyzeImage(image, { ...settings, signal: controller.signal, fetchImpl: (_url, { signal }) => {
    calls++;
    return new Promise((_resolve, reject) => signal.addEventListener('abort', () => reject(signal.reason), { once: true }));
  } });
  controller.abort();
  await assert.rejects(pending, { code: 'cancelled' });
  assert.equal(calls, 1);
});

test('limits repeated calls', async t => {
  const { post } = await withServer(t, { maxRequestsPerMinute: 1 });
  assert.equal((await post()).status, 200);
  await expectError(await post(), 429, 'rate_limited');
});

test('concurrent analyses are rejected while first finishes', async t => {
  let complete; let started;
  const seen = new Promise(resolve => { started = resolve; });
  const { post } = await withServer(t, { fetchImpl: () => { started(); return new Promise(resolve => { complete = resolve; }); } });
  const first = post(); await seen;
  await expectError(await post(), 429, 'busy');
  complete(upstream()); assert.equal((await first).status, 200);
});

test('malformed upstream JSON produces safe error', async t => {
  const { post } = await withServer(t, { fetchImpl: async () => new Response('not json private value') });
  await expectError(await post(), 502, 'upstream_error');
});

test('HTTP disconnect cancels the upstream request', async t => {
  let begin; let cancelled;
  const started = new Promise(resolve => { begin = resolve; });
  const aborted = new Promise(resolve => { cancelled = resolve; });
  const { url } = await withServer(t, { fetchImpl: (_url, { signal }) => {
    begin();
    return new Promise((_resolve, reject) => signal.addEventListener('abort', () => { cancelled(); reject(signal.reason); }, { once: true }));
  } });
  const req = http.request(`${url}/analyze`, { method: 'POST', headers: { 'Content-Type': 'application/json' } });
  req.on('error', () => {});
  req.end(JSON.stringify(image));
  await started;
  req.destroy();
  await aborted;
});
