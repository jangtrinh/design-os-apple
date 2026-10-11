#!/usr/bin/env node
'use strict';

// Preview-only dependencies are installed in runner temp, never in the Swift package.
// Run with NODE_PATH pointing to playwright@1.58.2 and marked@15.0.12.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const output = path.resolve(process.env.MARKETING_BROWSER_OUTPUT || path.join(require('node:os').tmpdir(), 'marketing-browser-results'));
fs.mkdirSync(output, { recursive: true });
const report = {
  status: 'running', startedAt: new Date().toISOString(),
  commit: process.env.GITHUB_SHA || null,
  tooling: { playwright: '1.58.2', marked: '15.0.12' },
  limitations: [
    'Static docs preview, not a deployed GitHub Pages/Jekyll build.',
    'README uses local marked rendering and preview CSS, not GitHub exact styling.',
    'Buy Me a Coffee third-party requests are intentionally blocked; the live widget and payment flow are NOT VERIFIED.',
    'Screenshots require human visual review; basic keyboard checks are not a full accessibility audit.',
    'External destinations are not visited or link-checked.'
  ],
  blockedRequests: [], checks: [], screenshots: []
};
const save = () => fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify(report, null, 2) + '\n');
save();
let browser, server;
async function check(name, fn) {
  try {
    const details = await fn();
    report.checks.push({ name, status: 'passed', ...(details === undefined ? {} : { details }) });
  } catch (error) {
    report.checks.push({ name, status: 'failed', error: String(error.stack || error) });
  }
  save();
}
function localFile(urlPath) {
  let relative = decodeURIComponent(urlPath);
  if (relative.startsWith('/design-os-apple/')) relative = '/docs/' + relative.slice('/design-os-apple/'.length);
  let file = path.resolve(root, '.' + relative);
  if (file !== root && !file.startsWith(root + path.sep)) return null;
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
  return file;
}
const mime = { '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript', '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.json': 'application/json' };
async function main() {
  const { chromium } = require('playwright');
  const { marked } = require('marked');
  const headingIds = new Map();
  marked.use({ renderer: {
    heading({ tokens, depth }) {
      const content = this.parser.parseInline(tokens);
      const slug = content.replace(/<[^>]*>/g, '').toLowerCase().replace(/[^\p{L}\p{N}_ -]/gu, '').replace(/ /g, '-');
      const count = headingIds.get(slug) || 0;
      headingIds.set(slug, count + 1);
      return `<h${depth} id="${slug}${count ? '-' + count : ''}">${content}</h${depth}>\n`;
    }
  } });
  assert.equal(require('playwright/package.json').version, report.tooling.playwright);
  assert.equal(require('marked/package.json').version, report.tooling.marked);
  const readme = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><base href="/"><title>README local rendering</title><style>
    *{box-sizing:border-box}body{margin:0;color:#1f2328;background:white;font:16px/1.6 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}main{max-width:1012px;margin:auto;padding:32px}img{max-width:100%;height:auto}pre{overflow:auto;padding:16px;background:#f6f8fa;border-radius:6px}code{font-family:monospace}table{display:block;overflow:auto;border-collapse:collapse}td,th{border:1px solid #d1d9e0;padding:6px 13px}a{color:#0969da}h1,h2{border-bottom:1px solid #d1d9e0}blockquote{margin-left:0;padding-left:16px;border-left:4px solid #d1d9e0;color:#59636e}:focus-visible{outline:3px solid #0969da;outline-offset:3px}@media(max-width:600px){main{padding:16px}}
  </style></head><body><main>${marked.parse(fs.readFileSync(path.join(root, 'README.md'), 'utf8')).replace(/href="#/g, 'href="/__readme-preview.html#')}</main></body></html>`;
  fs.writeFileSync(path.join(output, 'readme-preview.html'), readme);
  server = http.createServer((req, res) => {
    try {
      const pathname = new URL(req.url, 'http://localhost').pathname;
      if (pathname === '/__readme-preview.html') { res.writeHead(200, { 'Content-Type': 'text/html' }); return res.end(readme); }
      const file = localFile(pathname);
      if (!file || !fs.existsSync(file) || !fs.statSync(file).isFile()) { res.writeHead(404); return res.end('Not found'); }
      res.writeHead(200, { 'Content-Type': mime[path.extname(file)] || 'text/plain' });
      fs.createReadStream(file).pipe(res);
    } catch { res.writeHead(400); res.end('Bad request'); }
  });
  await new Promise((resolve, reject) => { server.once('error', reject); server.listen(0, '127.0.0.1', resolve); });
  const origin = `http://127.0.0.1:${server.address().port}`;
  browser = await chromium.launch({ headless: true });
  report.browserVersion = browser.version();
  for (const width of [375, 768, 1440]) {
    for (const kind of ['site', 'readme']) {
      const context = await browser.newContext({ viewport: { width, height: 1000 }, deviceScaleFactor: 1, reducedMotion: 'reduce' });
      const page = await context.newPage();
      page.setDefaultTimeout(10000);
      const errors = [], failedRequests = [], failedResponses = [];
      page.on('pageerror', e => errors.push(String(e)));
      page.on('response', response => {
        if (response.status() >= 400 && !isCoffee(response.url())) failedResponses.push({ url: response.url(), status: response.status() });
      });
      page.on('requestfailed', req => {
        if (!isCoffee(req.url())) failedRequests.push({ url: req.url(), error: req.failure()?.errorText });
      });
      await page.route('**/*', route => {
        if (isCoffee(route.request().url())) {
          report.blockedRequests.push(route.request().url());
          return route.abort('blockedbyclient');
        }
        return route.continue();
      });
      const prefix = `${kind}-${width}`;
      try {
        await check(`${prefix}: load`, async () => {
          const response = await page.goto(origin + (kind === 'site' ? '/design-os-apple/' : '/__readme-preview.html'), { waitUntil: 'load', timeout: 30000 });
          assert.equal(response.status(), 200);
          await page.evaluate(async () => {
            for (const img of document.images) img.loading = 'eager';
            await document.fonts.ready;
            await Promise.all([...document.images].map(img => img.complete ? Promise.resolve() : new Promise(resolve => { img.onload = img.onerror = resolve; setTimeout(resolve, 10000); })));
          });
        });
        // Capture before interaction assertions so failed tests still have visual evidence.
        await check(`${prefix}: screenshot`, async () => {
          const filename = `${prefix}.png`;
          await page.screenshot({ path: path.join(output, filename), fullPage: true, animations: 'disabled', timeout: 30000 });
          report.screenshots.push(filename);
        });
        await check(`${prefix}: loaded images`, async () => {
          const images = await page.locator('img').evaluateAll(imgs => imgs.map(i => ({ src: i.currentSrc || i.src, loaded: i.complete && i.naturalWidth > 0 && i.naturalHeight > 0 })));
          assert.ok(images.length > 0, 'Expected marketing images');
          assert.deepEqual(images.filter(i => !i.loaded), []);
          return { count: images.length };
        });
        await check(`${prefix}: no horizontal overflow`, async () => {
          const dimensions = await page.evaluate(() => ({ viewport: innerWidth, document: document.documentElement.scrollWidth, body: document.body.scrollWidth }));
          assert.ok(dimensions.document <= width + 1 && dimensions.body <= width + 1, JSON.stringify(dimensions));
          return dimensions;
        });
        await check(`${prefix}: local links`, async () => {
          const links = await page.locator('a[href]').evaluateAll(nodes => nodes.map(a => a.href));
          const local = [...new Set(links)].filter(href => new URL(href).origin === origin);
          for (const href of local) {
            const url = new URL(href);
            if (url.pathname === new URL(page.url()).pathname && url.hash) {
              assert.ok(await page.evaluate(id => !!document.getElementById(id), decodeURIComponent(url.hash.slice(1))), `Missing anchor: ${href}`);
            } else {
              const file = localFile(url.pathname);
              assert.ok(file && fs.existsSync(file), `Missing local path: ${href}`);
              const response = await context.request.get(href, { timeout: 10000 });
              assert.equal(response.status(), 200, `Local link did not load: ${href}`);
            }
          }
          return { count: local.length };
        });
        if (kind === 'site') await siteInteractions(page, prefix);
        await check(`${prefix}: page errors`, () => { assert.deepEqual(errors, []); assert.deepEqual(failedRequests, []); assert.deepEqual(failedResponses, []); });
      } finally { await context.close(); }
    }
  }
}
function isCoffee(url) { return /(^|\.)buymeacoffee\.com$|(^|\.)buymeacoffee\.com\.cdn\.cloudflare\.net$/i.test(new URL(url).hostname); }
async function siteInteractions(page, prefix) {
  await check(`${prefix}: FAQ click and keyboard`, async () => {
    const details = page.locator('details');
    const count = await details.count();
    assert.ok(count > 0, 'Expected native FAQ details');
    for (let i = 0; i < count; i++) {
      const item = details.nth(i), summary = item.locator('summary');
      if (await item.evaluate(el => el.open)) await summary.click();
      await summary.click();
      assert.ok(await item.evaluate(el => el.open), 'Click should open FAQ');
      await summary.press('Enter');
      assert.ok(!(await item.evaluate(el => el.open)), 'Enter should close FAQ');
      await summary.press('Space');
      assert.ok(await item.evaluate(el => el.open), 'Space should reopen FAQ');
      await summary.click();
      assert.ok(!(await item.evaluate(el => el.open)), 'Repeated click should close FAQ');
    }
    return { count };
  });
  await check(`${prefix}: in-page navigation`, async () => {
    const anchors = page.locator('a[href^="#"]');
    const count = await anchors.count();
    assert.ok(count > 0, 'Expected in-page navigation');
    for (let i = 0; i < count; i++) {
      const anchor = anchors.nth(i), hash = await anchor.getAttribute('href');
      if (hash === '#') continue;
      // Includes visually-hidden skip navigation: focus must reveal it.
      await anchor.focus();
      await anchor.press('Enter');
      await page.waitForFunction(expected => location.hash === expected, hash);
      assert.ok(await page.evaluate(id => !!document.getElementById(id), decodeURIComponent(hash.slice(1))));
    }
    return { count };
  });
  await check(`${prefix}: keyboard focus visible`, async () => {
    await page.goto(page.url().split('#')[0], { waitUntil: 'load' });
    await page.keyboard.press('Tab');
    const focus = await page.evaluate(() => {
      const el = document.activeElement, css = getComputedStyle(el), rect = el.getBoundingClientRect();
      return { tag: el.tagName, focusVisible: el.matches(':focus-visible'), indicator: (css.outlineStyle !== 'none' && parseFloat(css.outlineWidth) > 0) || css.boxShadow !== 'none', inViewport: rect.width > 0 && rect.height > 0 && rect.right > 0 && rect.left < innerWidth && rect.bottom > 0 && rect.top < innerHeight };
    });
    assert.ok(focus.tag !== 'BODY' && focus.focusVisible && focus.indicator && focus.inViewport, JSON.stringify(focus));
    return focus;
  });
}
// Bound the whole run and retain partial results even if a browser operation hangs.
const deadline = setTimeout(() => {
  report.status = 'failed';
  report.checks.push({ name: 'global timeout', status: 'failed', error: 'Preview exceeded five minutes.' });
  save();
  process.exit(1);
}, 5 * 60 * 1000);
main().catch(error => {
  report.checks.push({ name: 'preview setup/runtime', status: 'failed', error: String(error.stack || error) });
}).finally(async () => {
  clearTimeout(deadline);
  if (browser) await browser.close().catch(() => {});
  if (server) { server.closeAllConnections(); await new Promise(resolve => server.close(resolve)); }
  report.blockedRequests = [...new Set(report.blockedRequests)];
  report.status = report.checks.some(c => c.status === 'failed') ? 'failed' : 'passed';
  report.finishedAt = new Date().toISOString();
  save();
  console.log(JSON.stringify(report, null, 2));
  process.exitCode = report.status === 'passed' ? 0 : 1;
});
