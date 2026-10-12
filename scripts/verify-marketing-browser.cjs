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
    'Full-page screenshots are layout context; visible-section and individually painted preview captures establish below-fold image paint.',
    'Screenshots require human visual review; basic keyboard checks are not a full accessibility audit.',
    'External destinations are not visited or link-checked.',
    'Catalog entries with pending native evidence establish source coverage only, not native visual acceptance.',
    'Historical catalog screenshots remain bound to their original source revision and do not verify the current candidate.'
  ],
  blockedRequests: [], pageDiagnostics: [], checks: [], screenshots: []
};
const save = () => fs.writeFileSync(path.join(output, 'results.json'), JSON.stringify(report, null, 2) + '\n');
save();
let browser, server, activePage;
async function check(name, fn) {
  try {
    const details = await fn();
    report.checks.push({ name, status: 'passed', ...(details === undefined ? {} : { details }) });
  } catch (error) {
    report.checks.push({ name, status: 'failed', error: String(error.stack || error) });
    if (activePage && !activePage.isClosed()) {
      const filename = `failed-${name.replace(/[^a-z0-9]+/gi, '-').toLowerCase()}.png`;
      try {
        await activePage.screenshot({ path: path.join(output, filename), fullPage: true, animations: 'disabled', timeout: 10000 });
        report.screenshots.push(filename);
      } catch (captureError) { report.checks.at(-1).failureScreenshotError = String(captureError); }
    }
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
  await check('catalog: deterministic static inventory coverage', staticCatalogCoverage);
  await check('catalog: static guard negative controls', testStaticCatalogGuard);
  if (process.argv.includes('--static-only')) return;
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
    for (const kind of ['site', 'readme', 'catalog', 'catalog-no-js', 'architecture']) {
      const context = await browser.newContext({ viewport: { width, height: 1000 }, deviceScaleFactor: 1, reducedMotion: 'reduce', javaScriptEnabled: kind !== 'catalog-no-js' });
      const page = await context.newPage();
      activePage = page;
      page.setDefaultTimeout(10000);
      const errors = [], failedRequests = [], failedResponses = [];
      page.on('pageerror', e => errors.push(String(e)));
      page.on('crash', () => report.pageDiagnostics.push({kind,width,event:'crash'}));
      page.on('framenavigated', frame => { if (frame === page.mainFrame()) report.pageDiagnostics.push({kind,width,event:'navigation',url:frame.url()}); });
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
          const response = await page.goto(origin + (kind === 'site' ? '/design-os-apple/' : kind === 'architecture' ? '/design-os-apple/kit-architecture.html' : kind.startsWith('catalog') ? '/design-os-apple/components.html' : '/__readme-preview.html'), { waitUntil: 'load', timeout: 30000 });
          assert.equal(response.status(), 200);
          await page.evaluate(() => { for (const img of document.images) img.loading = 'eager'; });
          const loadDeadline = Date.now() + 30000;
          while (!(await page.evaluate(() => [...document.images].every(img => img.complete && img.naturalWidth > 0 && img.naturalHeight > 0)))) {
            if (Date.now() >= loadDeadline) throw new Error('Images did not finish loading: ' + JSON.stringify(await page.locator('img').evaluateAll(imgs => imgs.filter(img => !img.complete || !img.naturalWidth || !img.naturalHeight).map(img => ({src:img.currentSrc || img.src,complete:img.complete,width:img.naturalWidth,height:img.naturalHeight})))));
            await page.waitForTimeout(100);
          }
          // Keep scheduling in Node: no-JS pages must not depend on RAF, load
          // handlers or timer-backed promises injected into their page context.
          const seen = new Map();
          const geometry = await page.evaluate(() => ({ height: document.documentElement.scrollHeight, step: Math.max(1, innerHeight * 0.8) }));
          for (let y = 0; y < geometry.height; y += geometry.step) {
            await page.evaluate(position => scrollTo(0, position), y);
            await page.waitForTimeout(35);
            const visible = await page.locator('img').evaluateAll(imgs => imgs.map((img, index) => { const r=img.getBoundingClientRect(); return { index, src: new URL(img.currentSrc || img.src).pathname, width:r.width, height:r.height, naturalWidth:img.naturalWidth, naturalHeight:img.naturalHeight, visible:r.width>0 && r.height>0 && r.bottom>0 && r.top<innerHeight }; }).filter(img => img.visible));
            for (const item of visible) {
              if (seen.has(item.src)) continue;
              try { await page.locator('img').nth(item.index).evaluate(img => img.decode()); }
              catch (error) { throw new Error(`Visible image decode failed: ${item.src}; natural=${item.naturalWidth}x${item.naturalHeight}; ${error}`); }
              seen.set(item.src, { src:item.src, width:item.width, height:item.height, decoded:true, visitedWhileVisible:true });
            }
            await page.waitForTimeout(35);
          }
          const expected = await page.locator('img').evaluateAll(imgs => new Set(imgs.map(img => new URL(img.currentSrc || img.src).pathname)).size);
          assert.equal(seen.size, expected, 'Every image must be decoded while visible');
          await page.evaluate(() => scrollTo(0, 0));
          await page.waitForTimeout(35);
          return { decoded:seen.size, expected, images:[...seen.values()] };
        });
        // Capture before interaction assertions so failed tests still have visual evidence.
        await check(`${prefix}: screenshot`, async () => {
          const filename = `${prefix}.png`;
          await page.screenshot({ path: path.join(output, filename), fullPage: true, animations: 'disabled', timeout: 30000 });
          report.screenshots.push(filename);
          // Independent viewport captures make below-fold image paint auditable.
          const sections = kind === 'site' ? ['gallery'] : kind.startsWith('catalog') && [375, 1440].includes(width) ? ['semantic', 'composite', 'shells', 'screen-types', 'native-recipes'] : [];
          for (const id of sections) {
            await page.locator(`[id="${id}"]`).evaluate(el => el.scrollIntoView({ block: 'start' }));
            const visible = await page.locator('img').evaluateAll(imgs => imgs.map((img,index) => { const r=img.getBoundingClientRect(); return {index,visible:r.bottom>0 && r.top<innerHeight}; }).filter(i=>i.visible).map(i=>i.index));
            for (const index of visible) await page.locator('img').nth(index).evaluate(img => img.decode());
            await page.waitForTimeout(70);
            const sectionFile = `${prefix}-section-${id}.png`;
            await page.screenshot({ path: path.join(output, sectionFile), fullPage: false, animations: 'disabled', timeout: 30000 });
            report.screenshots.push(sectionFile);
          }
          if (kind === 'catalog' && width === 375) {
            const previews = page.locator('.component-preview img');
            assert.equal(await previews.count(), 142);
            for (let index = 0; index < await previews.count(); index++) {
              const preview = previews.nth(index);
              await preview.scrollIntoViewIfNeeded();
              await preview.evaluate(img => img.decode());
              await page.waitForTimeout(35);
              const asset = path.basename(await preview.getAttribute('src'), '.webp');
              const file = `painted-${asset}.png`;
              await preview.screenshot({ path:path.join(output,file), animations:'disabled', timeout:10000 });
              report.screenshots.push(file);
            }
          }
          await page.evaluate(() => scrollTo(0, 0));
        });
        await check(`${prefix}: loaded images`, async () => {
          const images = await page.locator('img').evaluateAll(imgs => imgs.map(i => ({ src: i.currentSrc || i.src, loaded: i.complete && i.naturalWidth > 0 && i.naturalHeight > 0 })));
          if (kind === 'architecture') assert.equal(images.length, 0, 'Architecture guide is text-only');
          else assert.ok(images.length > 0, 'Expected marketing images');
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
        if (kind.startsWith('catalog')) await catalogInteractions(page, prefix, kind === 'catalog');
        await check(`${prefix}: page errors`, () => { assert.deepEqual(errors, []); assert.deepEqual(failedRequests, []); assert.deepEqual(failedResponses, []); });
      } finally { activePage = null; await context.close(); }
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
function readCatalogInventory() {
  const inventory = JSON.parse(fs.readFileSync(path.join(root, 'docs/marketing/component-catalog.json'), 'utf8'));
  assert.equal(inventory.version, 1, 'Unsupported catalog inventory version');
  assert.ok(Array.isArray(inventory.groups) && inventory.groups.length > 0, 'Missing catalog groups');
  return { ...inventory, entries: inventory.groups.flatMap(group => group.items.map(item => ({ ...item, layer: group.id }))) };
}
function parseCatalog(html) {
  // Python's standard HTML parser avoids a runtime dependency and handles quoted
  // attributes/entities correctly. Validation never executes page JavaScript.
  const parser = String.raw`
import json, sys
from html.parser import HTMLParser
class CatalogParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.nodes=[]; self.stack=[]
    def handle_starttag(self, tag, attrs):
        node={'tag':tag,'attrs':dict(attrs),'text':'','images':[],'links':[]}
        self.nodes.append(node)
        if tag=='img':
            for parent in self.stack: parent['images'].append(dict(attrs))
        if tag=='a':
            for parent in self.stack: parent['links'].append(dict(attrs).get('href',''))
        if tag not in ['area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr']: self.stack.append(node)
    def handle_endtag(self, tag):
        for i in range(len(self.stack)-1,-1,-1):
            if self.stack[i]['tag']==tag:
                del self.stack[i:]; break
    def handle_data(self, data):
        for node in self.stack: node['text']+=data
p=CatalogParser(); p.feed(sys.stdin.read()); print(json.dumps(p.nodes))
`;
  return JSON.parse(require('node:child_process').execFileSync('python3', ['-c', parser], { input: html, maxBuffer: 32 * 1024 * 1024, encoding: 'utf8' }));
}
function staticCatalogCoverage(options = {}) {
  const inventory = options.inventory || readCatalogInventory();
  const html = options.html ?? fs.readFileSync(path.join(root, 'docs/components.html'), 'utf8');
  const nodes = parseCatalog(html);
  const withClass = name => nodes.filter(n => (n.attrs.class || '').split(/\s+/).includes(name));
  const entries = withClass('component-entry'), groups = withClass('catalog-group');
  const expectedIds = inventory.entries.map(e => e.id).sort();
  assert.equal(new Set(expectedIds).size, expectedIds.length, 'Duplicate inventory entry IDs');
  assert.ok(expectedIds.length > 0, 'Empty catalog inventory');
  assert.equal(inventory.counts.records, expectedIds.length, 'Declared record count differs');
  for (const group of inventory.groups) assert.equal(inventory.counts.byGroup[group.id], group.items.length, `Declared group count differs: ${group.id}`);
  const allIds = nodes.filter(n => n.attrs.id).map(n => n.attrs.id);
  assert.equal(new Set(allIds).size, allIds.length, 'Duplicate HTML IDs');
  assert.deepEqual(entries.map(e => e.attrs.id).sort(), expectedIds, 'Missing, duplicated or invented rendered entry');
  assert.deepEqual(groups.map(g => g.attrs['data-group']).sort(), inventory.groups.map(g => g.id).sort(), 'Group coverage differs');
  for (const group of groups) assert.ok(!Object.hasOwn(group.attrs, 'hidden'), `Group hidden without JavaScript: ${group.attrs.id}`);
  for (const item of inventory.entries) {
    const entry = entries.find(e => e.attrs.id === item.id);
    assert.equal(entry.attrs['data-layer'], item.layer, `Wrong layer: ${item.id}`);
    assert.ok(!Object.hasOwn(entry.attrs, 'hidden'), `Entry hidden without JavaScript: ${item.id}`);
    assert.ok(entry.text.includes(item.name), `Missing entry name: ${item.id}`);
    assert.ok(item.source && /^[a-f0-9]{40}$/.test(item.source.commit), `Missing source commit: ${item.id}`);
    const sourcePath = path.resolve(root, item.source.path);
    assert.ok(sourcePath.startsWith(root + path.sep), `Source outside checkout: ${item.id}`);
    // The merged source is present: verify actual bytes and declared initializer text.
    const sourceBytes = fs.readFileSync(sourcePath);
    assert.equal(require('node:crypto').createHash('sha256').update(sourceBytes).digest('hex'), item.source.sha256, `Stale source digest: ${item.id}`);
    const normalize = value => value.replace(/\s+/g, '');
    for (const initializer of item.configuration?.initializers || []) assert.ok(normalize(sourceBytes.toString()).includes(normalize(initializer)), `Invented initializer: ${item.id}`);
    assert.match(item.source.sha256, /^[a-f0-9]{64}$/, `Missing source digest: ${item.id}`);
    assert.equal(item.source.commit, inventory.sourceCommit, `Unpinned source revision: ${item.id}`);
    assert.equal(item.source.url, `https://github.com/jangtrinh/design-os-apple/blob/${item.source.commit}/${item.source.path}`, `Wrong source permalink: ${item.id}`);
    assert.ok(entry.links.includes(item.source.url), `Missing source permalink: ${item.id}`);
    assert.ok(item.review && item.review.status && item.review.detail, `Missing honest review state: ${item.id}`);
    assert.ok(['source-only', 'native-capture', 'historical-native-capture'].includes(item.review.status), `Unsupported or falsely promoted visual status: ${item.id}`);
    assert.match(item.review.detail, /(?:no independent|pending|unverified|not established|not .*acceptance)/i, `Independent visual acceptance must remain unclaimed: ${item.id}`);
    assert.ok(entry.text.includes(item.review.detail), `Review caveat missing from HTML: ${item.id}`);
    const badge = { 'source-only': 'Source inspected · no standalone preview', 'native-capture': 'Native capture · source matched', 'historical-native-capture': 'Historical native capture · current review pending' }[item.review.status];
    assert.ok(entry.text.includes(badge), `Wrong source-bound review badge: ${item.id}`);
    if (item.preview) {
      assert.ok(item.preview.src && item.preview.alt && item.preview.caption, `Incomplete image evidence: ${item.id}`);
      const sources = [item.preview.src, item.preview.darkSrc].filter(Boolean);
      assert.deepEqual(entry.images.map(i => i.src), sources, `Preview differs from inventory: ${item.id}`);
      assert.equal(entry.images[0].alt, item.preview.alt + (item.preview.darkSrc ? ' · light' : ''), `Preview alt text mismatch: ${item.id}`);
      if (item.preview.darkSrc) assert.equal(entry.images[1].alt, item.preview.alt + ' · dark', `Dark preview alt text mismatch: ${item.id}`);
      assert.ok(entry.text.includes(item.preview.caption), `Missing preview provenance caption: ${item.id}`);
      for (let i = 0; i < sources.length; i++) {
        const manifest = JSON.parse(fs.readFileSync(path.join(root, 'docs/assets/components/manifest.json'), 'utf8'));
        const asset = manifest.assets.find(a => `assets/components/${a.file}` === sources[i]);
        assert.ok(asset && asset.component_id === item.id, `Wrong component image mapping: ${item.id}`);
        assert.equal(asset.appearance, i === 0 ? 'light' : 'dark', `Wrong appearance: ${item.id}`);
        const captureCommit = manifest.source.head_sha;
        assert.equal(item.preview.sourceCommit, captureCommit, `Relabeled screenshot source revision: ${item.id}`);
        const historical = captureCommit !== inventory.sourceCommit;
        assert.equal(item.preview.historical, historical, `Incorrect historical evidence flag: ${item.id}`);
        assert.equal(item.review.status, historical ? 'historical-native-capture' : 'native-capture', `Falsely promoted native evidence: ${item.id}`);
        if (historical) {
          assert.match(item.preview.caption, /historical/i, `Historical caption missing: ${item.id}`);
          assert.match(item.preview.caption, /pending|unverified/i, `Current capture limitation missing: ${item.id}`);
          assert.ok(item.preview.caption.includes(captureCommit.slice(0, 7)), `Historical source not disclosed: ${item.id}`);
          assert.ok(item.preview.caption.includes(inventory.sourceCommit.slice(0, 7)), `Current candidate not disclosed: ${item.id}`);
          assert.match(item.review.detail, /historical/i, `Historical review disclosure missing: ${item.id}`);
        }
      }
    } else {
      assert.equal(item.review.status, 'source-only', `Native status without published evidence: ${item.id}`);
      assert.deepEqual(entry.images, [], `Invented component image: ${item.id}`);
      assert.match(entry.text, /no standalone|not yet|not reviewed/i, `No native evidence but no pending disclosure: ${item.id}`);
    }
  }
  const reviewCounts = {};
  for (const entry of inventory.entries) reviewCounts[entry.review.status] = (reviewCounts[entry.review.status] || 0) + 1;
  assert.deepEqual(inventory.counts.byReviewStatus, reviewCounts, 'Declared review counts differ');
  const tokens = withClass('catalog-token');
  assert.ok(Array.isArray(inventory.tokens) && inventory.tokens.length > 0, 'Missing token inventory');
  assert.equal(new Set(inventory.tokens.map(t => t.id)).size, inventory.tokens.length, 'Duplicate token inventory IDs');
  assert.deepEqual(tokens.map(t => t.attrs.id).sort(), inventory.tokens.map(t => t.id).sort(), 'Token coverage differs');
  for (const token of inventory.tokens) {
    const rendered = tokens.find(t => t.attrs.id === token.id);
    assert.ok(!Object.hasOwn(rendered.attrs, 'hidden'), `Token hidden without JavaScript: ${token.id}`);
    assert.ok(rendered.text.includes(token.path), `Missing token label: ${token.id}`);
    const value = token.value && typeof token.value === 'object' ? Object.entries(token.value).map(([key, val]) => `${key}: ${val}`).join('; ') : String(token.value);
    assert.ok(rendered.text.includes(value), `Incorrect token value: ${token.id}`);
  }
  const evidence = withClass('component-evidence');
  assert.equal(evidence.length, entries.length, 'Missing review disclosure');
  for (const item of evidence) assert.match(item.text, /^(?:Source inspected · no standalone preview|Native capture · source matched|Historical native capture · current review pending)/, 'False visual status badge');
  const approvedImages = new Map();
  for (const [directory, digest] of [
    ['marketing', '8d41bcc4d4972815526432b09677b4657f5ecf70470a5ad4aec25a7c0a8feb27'],
    ['components', '53322222c939046166e7994dfd28601c0ef8db00a84cde625f1f623a37394775']
  ]) {
    const bytes = fs.readFileSync(path.join(root, `docs/assets/${directory}/manifest.json`));
    assert.equal(require('node:crypto').createHash('sha256').update(bytes).digest('hex'), digest, `Unreviewed ${directory} manifest`);
    for (const asset of JSON.parse(bytes).assets) approvedImages.set(`assets/${directory}/${asset.file}`, asset);
  }
  const images = nodes.filter(n => n.tag === 'img');
  assert.ok(images.length > 0, 'Catalog lacks native context images');
  for (const img of images) {
    assert.ok(img.attrs.alt, `Image missing accessible description: ${img.attrs.src}`);
    assert.ok(!img.attrs.srcset, 'Catalog images must have one auditable source');
    const src = img.attrs.src;
    assert.ok(src && !/^(?:[a-z]+:|\/\/)/i.test(src), `External or inline catalog image: ${src}`);
    const imagePath = path.resolve(root, 'docs', src);
    assert.ok(imagePath.startsWith(path.join(root, 'docs') + path.sep), `Image outside docs: ${src}`);
    assert.ok(fs.existsSync(imagePath) && fs.statSync(imagePath).isFile(), `Missing catalog image: ${src}`);
    assert.equal(fs.realpathSync(imagePath), imagePath, `Symlink catalog image: ${src}`);
    const approved = approvedImages.get(src);
    assert.ok(approved, `Unreviewed catalog image: ${src}`);
    assert.equal(require('node:crypto').createHash('sha256').update(fs.readFileSync(imagePath)).digest('hex'), approved.sha256, `Image hash mismatch: ${src}`);
  }
  return { entries: entries.length, groups: groups.length, tokenValues: tokens.length, images: images.length, inventory: 'docs/marketing/component-catalog.json', mode: 'static HTML; JavaScript not executed' };
}

function testStaticCatalogGuard() {
  staticCatalogCoverage(); // Negative controls must not pass merely because the baseline is broken.
  const inventory = readCatalogInventory();
  const html = fs.readFileSync(path.join(root, 'docs/components.html'), 'utf8');
  const firstId = inventory.entries[0].id;
  let rejected = 0;
  function rejects(label, mutation) {
    assert.throws(() => staticCatalogCoverage(mutation), undefined, `Guard accepted ${label}`);
    rejected++;
  }
  rejects('missing entry', { html: html.replace(`id="${firstId}"`, 'id="fabricated-entry"') });
  rejects('duplicate ID', { html: html.replace(`id="${inventory.entries[1].id}"`, `id="${firstId}"`) });
  rejects('hidden default entry', { html: html.replace(`id="${firstId}"`, `hidden id="${firstId}"`) });
  const duplicate = structuredClone(inventory); duplicate.entries.push(duplicate.entries[0]);
  rejects('duplicate inventory entry', { inventory: duplicate });
  const promotion = structuredClone(inventory); promotion.entries[0].review.status = 'visuallyreviewed';
  rejects('unreviewed visual promotion', { inventory: promotion });
  const nativeIndex = inventory.entries.findIndex(entry => entry.preview);
  assert.ok(nativeIndex >= 0, 'Expected source-bound historical/native image controls');
  const relabeledCapture = structuredClone(inventory);
  relabeledCapture.entries[nativeIndex].preview.sourceCommit = '0'.repeat(40);
  rejects('relabeled screenshot source revision', { inventory: relabeledCapture });
  const historicalIndex = inventory.entries.findIndex(entry => entry.preview?.historical);
  if (historicalIndex >= 0) {
    rejects('historical badge promoted to current native capture', { html: html.replace('Historical native capture · current review pending', 'Native capture · source matched') });
    const currentPromotion = structuredClone(inventory);
    currentPromotion.entries[historicalIndex].review.status = 'native-capture';
    rejects('historical capture promoted to current candidate', { inventory: currentPromotion });
    const hiddenHistory = structuredClone(inventory);
    hiddenHistory.entries[historicalIndex].preview.historical = false;
    rejects('historical evidence flag removed', { inventory: hiddenHistory });
    const falseCurrentSource = structuredClone(inventory);
    falseCurrentSource.entries[historicalIndex].preview.sourceCommit = inventory.sourceCommit;
    rejects('historical screenshot assigned current source', { inventory: falseCurrentSource });
    const missingHistoricalCaption = structuredClone(inventory);
    missingHistoricalCaption.entries[historicalIndex].preview.caption = 'Native capture verified for the current candidate.';
    rejects('historical limitation removed', { inventory: missingHistoricalCaption });
  }
  const firstImage = inventory.entries[nativeIndex].preview.src;
  rejects('missing image', { html: html.replace(`src="${firstImage}"`, 'src="assets/components/does-not-exist.webp"') });
  rejects('false visual status badge', { html: html.replace('Source inspected · no standalone preview', 'Visually reviewed · accepted') });
  rejects('missing token', { html: html.replace(`id="${inventory.tokens[0].id}"`, 'id="invented-token"') });
  rejects('external reference image', { html: html.replace(`src="${firstImage}"`, 'src="https://example.com/reference.png"') });
  const staleSource = structuredClone(inventory); staleSource.entries[0].source.sha256 = '0'.repeat(64);
  rejects('stale source hash', { inventory: staleSource });
  const inventedAPI = structuredClone(inventory); inventedAPI.entries[0].configuration = { initializers: ['public init(inventedParameter: ImpossibleType)'] };
  rejects('invented initializer', { inventory: inventedAPI });
  const wrongAppearance = structuredClone(inventory); wrongAppearance.entries[nativeIndex].preview.darkSrc = wrongAppearance.entries[nativeIndex].preview.src;
  rejects('light image substituted for dark', { inventory: wrongAppearance });
  return { rejectedMutations: rejected };
}

async function catalogInteractions(page, prefix, enhanced) {
  const entries = page.locator('#catalog-content .component-entry[data-layer]');
  const groups = page.locator('#catalog-content .catalog-group[data-group]');
  const inventory = readCatalogInventory();
  const expected = inventory.entries.map(entry => entry.id).sort();
  await check(`${prefix}: complete inventory visible by default`, async () => {
    const rendered = await entries.evaluateAll(nodes => nodes.map(n => n.dataset.entryId || n.id).sort());
    assert.deepEqual(rendered, expected);
    for (let i = 0; i < await entries.count(); i++) assert.ok(await entries.nth(i).isVisible(), `Hidden entry ${i}`);
    for (let i = 0; i < await groups.count(); i++) assert.ok(await groups.nth(i).isVisible(), `Hidden group ${i}`);
    assert.ok(await groups.count() > 0);
    const tokens = page.locator('.catalog-token');
    assert.deepEqual(await tokens.evaluateAll(nodes => nodes.map(n => n.id).sort()), inventory.tokens.map(t => t.id).sort());
    for (let i = 0; i < await tokens.count(); i++) assert.ok(await tokens.nth(i).isVisible(), `Hidden token ${i}`);
    return { entries: rendered.length, groups: await groups.count(), javaScriptEnabled: enhanced };
  });
  if (page.viewportSize().width <= 650) await check(`${prefix}: mobile section rail`, async () => {
    const rail = page.locator('.catalog-toc');
    const metrics = await rail.evaluate(el => ({ wrap: getComputedStyle(el).flexWrap, width: el.clientWidth, scroll: el.scrollWidth }));
    assert.equal(metrics.wrap, 'nowrap');
    assert.ok(metrics.scroll > metrics.width, 'Expected contained horizontal section rail');
    const last = rail.locator('a').last(); await last.focus();
    const visible = await last.evaluate(el => { const a=el.getBoundingClientRect(), r=el.parentElement.getBoundingClientRect(); return a.left >= r.left-1 && a.right <= r.right+1; });
    assert.ok(visible, 'Focused section link must scroll into view');
    assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1));
    return metrics;
  });
  await check(`${prefix}: progressive enhancement controls`, async () => {
    assert.equal(await page.locator('.catalog-tools').isVisible(), enhanced);
    assert.equal(await page.locator('#catalog-empty').isVisible(), false);
    if (enhanced) {
      assert.match(await page.locator('#catalog-status').innerText(), new RegExp(`${expected.length} of ${expected.length} entries shown`));
      assert.equal(await page.locator('#catalog-status').getAttribute('aria-live'), 'polite');
    }
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
  if (enhanced) {
    await check(`${prefix}: layer filters and keyboard activation`, async () => {
      const filters = page.locator('button[data-filter]');
      const values = await filters.evaluateAll(nodes => nodes.map(n => n.dataset.filter));
      assert.deepEqual([...values].sort(), ['all', ...new Set(inventory.entries.map(e => e.layer))].sort());
      assert.equal(new Set(values).size, values.length, 'Duplicate filter');
      for (let i = 0; i < values.length; i++) {
        const filter = filters.nth(i), layer = values[i];
        await filter.focus();
        await filter.press(i % 2 ? 'Space' : 'Enter');
        assert.equal(await filter.getAttribute('aria-pressed'), 'true');
        assert.equal(await page.locator('button[data-filter][aria-pressed="true"]').count(), 1);
        const visible = await entries.evaluateAll(nodes => nodes.filter(n => !n.hidden).map(n => n.dataset.entryId || n.id).sort());
        const wanted = inventory.entries.filter(e => layer === 'all' || e.layer === layer).map(e => e.id).sort();
        assert.deepEqual(visible, wanted);
        const tokenCount = await page.locator('.catalog-token').evaluateAll(nodes => nodes.filter(n => !n.hidden).length);
        assert.equal(tokenCount, layer === 'all' || layer === 'foundations' ? inventory.tokens.length : 0);
        assert.match(await page.locator('#catalog-status').innerText(), new RegExp(`${wanted.length} of ${expected.length} entries shown`));
        const emptyVisibleGroups = await groups.evaluateAll(nodes => nodes.filter(g => !g.hidden && ![...g.querySelectorAll('.component-entry')].some(n => !n.hidden)).map(g => g.id));
        assert.deepEqual(emptyVisibleGroups, []);
      }
      await page.locator('#catalog-reset').click();
      return { filters: values };
    });
    await check(`${prefix}: search, no results and reset`, async () => {
      const search = page.locator('#catalog-search');
      const first = entries.first();
      const term = (await first.locator('h3').innerText()).trim();
      assert.ok(term.length > 0);
      const expectedMatches = await entries.evaluateAll((nodes, value) => {
        const normalize = text => text.normalize('NFKD').toLowerCase();
        const words = normalize(value).split(/\s+/).filter(Boolean);
        return nodes.filter(n => words.every(w => normalize(n.textContent).includes(w))).map(n => n.dataset.entryId || n.id).sort();
      }, term);
      await search.fill(term.toUpperCase());
      assert.deepEqual(await entries.evaluateAll(nodes => nodes.filter(n => !n.hidden).map(n => n.dataset.entryId || n.id).sort()), expectedMatches);
      await search.fill('zzzz-no-component-can-match-43859');
      assert.equal(await entries.evaluateAll(nodes => nodes.filter(n => !n.hidden).length), 0);
      assert.equal(await groups.evaluateAll(nodes => nodes.filter(n => !n.hidden).length), 0);
      assert.equal(await page.locator('.catalog-token').evaluateAll(nodes => nodes.filter(n => !n.hidden).length), 0);
      assert.ok(await page.locator('#catalog-empty').isVisible());
      assert.match(await page.locator('#catalog-status').innerText(), new RegExp(`0 of ${expected.length} entries shown`));
      await page.locator('#catalog-reset').focus();
      await page.keyboard.press('Enter');
      assert.equal(await search.inputValue(), '');
      assert.ok(await search.evaluate(n => n === document.activeElement));
      assert.equal(await entries.evaluateAll(nodes => nodes.filter(n => !n.hidden).length), expected.length);
      assert.equal(await page.locator('#catalog-empty').isVisible(), false);
      assert.equal(await page.locator('button[data-filter="all"]').getAttribute('aria-pressed'), 'true');
      await search.fill(inventory.tokens[0].path);
      assert.ok(await page.locator(`[id="${inventory.tokens[0].id}"]`).isVisible(), 'Token-only search must reveal its token');
      assert.equal(await page.locator('#catalog-empty').isVisible(), false, 'A token match is a result');
      await page.locator('button[data-filter="screen-types"]').click();
      assert.equal(await page.locator('.catalog-token').evaluateAll(nodes => nodes.filter(n => !n.hidden).length), 0, 'Layer and token query must combine');
      await page.locator('#catalog-reset').click();
    });
    await check(`${prefix}: hidden entry deep link restores results`, async () => {
      const id = inventory.entries[0].id;
      await page.locator('#catalog-search').fill('zzzz-no-component-can-match-43859');
      await page.evaluate(target => { location.hash = target; }, id);
      await page.waitForFunction(target => !document.getElementById(target).hidden, id);
      assert.ok(await page.locator(`[id="${id}"]`).isVisible());
      assert.equal(await page.locator('#catalog-search').inputValue(), '');
    });
  }
  await check(`${prefix}: native group anchor navigation`, async () => {
    const anchors = page.locator('.catalog-toc a[href^="#"]');
    const count = await anchors.count();
    assert.ok(count >= await groups.count());
    for (let i = 0; i < count; i++) {
      const anchor = anchors.nth(i), hash = await anchor.getAttribute('href');
      if (enhanced) await page.locator('#catalog-search').fill('zzzz-no-component-can-match-43859');
      await anchor.focus();
      await anchor.press('Enter');
      await page.waitForFunction(expectedHash => location.hash === expectedHash, hash);
      // location.hash changes synchronously; hashchange handlers run in a later
      // browser task. Wait for their required UI effect, then assert it. This
      // retains the visibility requirement and the existing 10-second deadline.
      await page.locator(hash).waitFor({ state: 'visible' });
      assert.ok(await page.locator(hash).isVisible(), `Anchor target hidden: ${hash}`);
      if (enhanced) {
        await page.waitForFunction(() => document.getElementById('catalog-search').value === '');
        assert.equal(await page.locator('#catalog-search').inputValue(), '');
        assert.equal(await entries.evaluateAll(nodes => nodes.filter(n => !n.hidden).length), expected.length);
        // Re-selecting the current fragment does not dispatch hashchange. The
        // actual anchor activation must still restore a group hidden by search.
        await page.locator('#catalog-search').fill('zzzz-no-component-can-match-43859');
        assert.equal(await page.locator(hash).isVisible(), hash === '#native-evidence', 'Only catalog entries and token values are filtered; the evidence index remains accessible');
        await anchor.focus();
        await anchor.press('Enter');
        await page.locator(hash).waitFor({ state: 'visible' });
        assert.equal(await page.locator('#catalog-search').inputValue(), '');
        assert.equal(await entries.evaluateAll(nodes => nodes.filter(n => !n.hidden).length), expected.length);
      }
    }
    return { count, repeatedCurrentHash: enhanced };
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
