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
  // A deep link must remain reachable even after a filter hid its group.
  function revealAnchor() {
    const target = document.getElementById(decodeURIComponent(location.hash.slice(1)));
    if (target && (target.matches('.component-entry, .catalog-group, .catalog-token, .catalog-token-section') || target.closest('.component-entry'))) {
      layer = 'all'; search.value = ''; apply(); target.scrollIntoView();
    }
  }
  addEventListener('hashchange', revealAnchor);
  tools.hidden = false;
  apply();
  revealAnchor();
})();
