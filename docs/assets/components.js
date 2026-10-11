/* Progressive enhancement: the complete, source-backed catalog works without JS. */
(() => {
  'use strict';
  const entries = [...document.querySelectorAll('.component-entry')];
  const groups = [...document.querySelectorAll('.catalog-group')];
  const search = document.getElementById('catalog-search');
  const status = document.getElementById('catalog-status');
  const empty = document.getElementById('catalog-empty');
  const buttons = [...document.querySelectorAll('[data-filter]')];
  const tools = document.querySelector('.catalog-tools');
  const tokens = [...document.querySelectorAll('.catalog-token')];
  const tokenSection = document.querySelector('.catalog-token-section');
  if (!search || !entries.length) return;
  let layer = 'all';
  const normalize = value => value.normalize('NFKD').toLowerCase();
  const index = new Map(entries.map(entry => [entry, normalize(entry.textContent)]));
  function apply() {
    const words = normalize(search.value.trim()).split(/\s+/).filter(Boolean);
    let count = 0;
    for (const entry of entries) {
      const match = (layer === 'all' || entry.dataset.layer === layer) && words.every(word => index.get(entry).includes(word));
      entry.hidden = !match;
      if (match) count++;
    }
    for (const group of groups) {
      const visible = [...group.querySelectorAll('.component-entry')].filter(entry => !entry.hidden).length;
      group.hidden = visible === 0;
      group.querySelector('.catalog-group-count').textContent = `${visible} ${visible === 1 ? 'entry' : 'entries'}`;
    }
    let tokenCount = 0;
    for (const token of tokens) {
      token.hidden = !((layer === 'all' || layer === 'foundations') && words.every(word => normalize(token.textContent).includes(word)));
      if (!token.hidden) tokenCount++;
    }
    for (const type of document.querySelectorAll('.token-type')) type.hidden = ![...type.querySelectorAll('.catalog-token')].some(token => !token.hidden);
    if (tokenSection) tokenSection.hidden = tokenCount === 0;
    for (const button of buttons) button.setAttribute('aria-pressed', String(button.dataset.filter === layer));
    status.textContent = `${count} of ${entries.length} entries shown${layer !== 'all' ? ' in ' + buttons.find(button => button.dataset.filter === layer).textContent : ''}.`;
    status.textContent += ` ${tokenCount} of ${tokens.length} token values shown.`;
    empty.hidden = count !== 0 || tokenCount !== 0;
  }
  search.addEventListener('input', apply);
  buttons.forEach(button => button.addEventListener('click', () => { layer = button.dataset.filter; apply(); }));
  document.getElementById('catalog-reset').addEventListener('click', () => { layer = 'all'; search.value = ''; apply(); search.focus(); });
  // Resolve the intended link, not the previous location hash. Clicking the
  // current hash does not emit hashchange, but must still reveal filtered content.
  function revealAnchor(hash = location.hash) {
    let id;
    try { id = decodeURIComponent(hash.slice(1)); } catch { return; }
    const target = document.getElementById(id);
    if (target && (target.matches('.component-entry, .catalog-group, .catalog-token, .catalog-token-section') || target.closest('.component-entry'))) {
      layer = 'all'; search.value = ''; apply();
      for (let ancestor = target.parentElement; ancestor; ancestor = ancestor.parentElement) {
        if (ancestor.tagName === 'DETAILS') ancestor.open = true;
      }
      target.scrollIntoView();
    }
  }
  document.addEventListener('click', event => {
    if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    const anchor = event.target instanceof Element ? event.target.closest('a[href]') : null;
    if (!anchor || anchor.hasAttribute('download') || (anchor.target && anchor.target !== '_self')) return;
    const url = new URL(anchor.href, location.href);
    if (url.origin === location.origin && url.pathname === location.pathname && url.search === location.search && url.hash && url.hash === location.hash) revealAnchor(url.hash);
    // Preserve the browser's native hash navigation and keyboard focus behavior.
  });
  addEventListener('hashchange', () => revealAnchor(location.hash));
  tools.hidden = false;
  apply();
  revealAnchor();
})();
