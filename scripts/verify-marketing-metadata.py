#!/usr/bin/env python3
"""Check the existing design-os-github-page machine pack against actual page content.

Local checks establish markup/content consistency, not indexing, rankings or AI citations.
"""
import json,re,sys,hashlib
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlparse
from xml.etree import ElementTree as ET
R=Path(__file__).resolve().parent.parent;BASE='https://jangtrinh.github.io/design-os-apple/'
VOID={'area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr'}
class Page(HTMLParser):
 def __init__(self,text):
  super().__init__(convert_charrefs=True);self.nodes=[];self.stack=[];self.errors=[];self.feed(text)
 def handle_starttag(self,tag,attrs):
  n={'tag':tag,'attrs':dict(attrs),'text':'','children':[]};self.nodes.append(n)
  if self.stack:self.stack[-1]['children'].append(n)
  if tag not in VOID:self.stack.append(n)
 def handle_endtag(self,tag):
  if tag in VOID:return
  if not self.stack:self.errors.append('unexpected end '+tag);return
  n=self.stack.pop()
  if n['tag']!=tag:self.errors.append('tag balance '+n['tag']+'/'+tag)
 def handle_data(self,data):
  for n in self.stack:n['text']+=data
 def select(self,tag):return [n for n in self.nodes if n['tag']==tag]
def norm(s):return ' '.join(s.split())
def validate():
 pages={}
 for name in ['index.html','components.html','kit-architecture.html']:
  raw=(R/'docs'/name).read_text();p=Page(raw);pages[name]=p
  assert not p.errors and not p.stack,(name,p.errors,'unclosed tags' if p.stack else '')
  assert not re.search(r'\bluma\b|lu\.ma',raw,re.I),f'Unrequested inspiration-brand reference in {name}'
  assert len(p.select('h1'))==1,(name,'one H1 required')
  assert len(p.select('title'))==1 and 'Apple Design OS' in p.select('title')[0]['text'],(name,'descriptive title')
  metas={n['attrs'].get('name',n['attrs'].get('property')):n['attrs'].get('content','') for n in p.select('meta')}
  for key in ['description','robots','og:title','og:description','og:url','og:image','og:image:alt','twitter:card','twitter:image','twitter:image:alt']:
   assert metas.get(key),(name,'missing '+key)
  assert 'noindex' not in metas['robots'].lower(),(name,'unexpected noindex')
  canonical=[n['attrs']['href'] for n in p.select('link') if n['attrs'].get('rel')=='canonical'];want=BASE+('' if name=='index.html' else name)
  assert canonical==[want] and metas['og:url']==want,(name,'canonical/OG mismatch')
  assert any(n['attrs'].get('rel')=='alternate' and n['attrs'].get('type')=='text/plain' and n['attrs'].get('href','').endswith('llms.txt') for n in p.select('link')),(name,'llms link missing')
  for n in p.select('img'):
   a=n['attrs'];assert a.get('alt') and int(a.get('width','0'))>0 and int(a.get('height','0'))>0,(name,'image accessibility/dimensions')
   if name=='components.html':assert a.get('loading')=='lazy' and a.get('decoding')=='async','catalog loading policy'
  schemas=[json.loads(n['text']) for n in p.select('script') if n['attrs'].get('type')=='application/ld+json'];assert schemas,(name,'structured content absent')
  for s in schemas:assert s.get('@context')=='https://schema.org',(name,'schema context')
 # Mandatory template FAQ engine: five actual answers, identical JSON-LD and README.
 home=pages['index.html'];schema=json.loads(next(n['text'] for n in home.select('script') if n['attrs'].get('type')=='application/ld+json'))
 faq=next(n for n in schema['@graph'] if n.get('@type')=='FAQPage')['mainEntity'];assert len(faq)==5,'template requires five FAQ items'
 visible={}
 for details in home.select('details'):
  summaries=[n for n in details['children'] if n['tag']=='summary'];paragraphs=[n for n in details['children'] if n['tag']=='p']
  if summaries and paragraphs:visible[norm(summaries[0]['text'])]=norm(' '.join(n['text'] for n in paragraphs))
 readme=(R/'README.md').read_text();faqmd=readme.split('## Frequently asked questions',1)[1].split('\n## ',1)[0]
 md={norm(q):norm(a) for q,a in re.findall(r'### ([^\n]+)\n\n(.*?)(?=\n### |\Z)',faqmd,re.S)}
 for q in faq:
  name=norm(q['name']);answer=norm(q['acceptedAnswer']['text']);assert visible.get(name)==answer,('visible/schema FAQ mismatch',name);assert md.get(name)==answer,('README/Pages FAQ mismatch',name)
 source=next(n for n in schema['@graph'] if n.get('@type')=='SoftwareSourceCode');assert source['codeRepository']=='https://github.com/jangtrinh/design-os-apple';assert source['version']=='1898ce28861d642f57dccd88fd57afcbe3be5bb9';assert source['author']['url']=='https://github.com/jangtrinh';assert source['license'].endswith('/LICENSE')
 sitemap=ET.parse(R/'docs/sitemap.xml');ns={'s':'http://www.sitemaps.org/schemas/sitemap/0.9','image':'http://www.google.com/schemas/sitemap-image/1.1'};urls=sitemap.findall('s:url',ns);locations=[u.findtext('s:loc',namespaces=ns) for u in urls];assert set(locations)=={BASE,BASE+'components.html',BASE+'kit-architecture.html'},'sitemap routes differ'
 catalog=next(u for u in urls if u.findtext('s:loc',namespaces=ns)==BASE+'components.html');images=[n.text for n in catalog.findall('image:image/image:loc',ns)];manifest=json.loads((R/'docs/assets/components/manifest.json').read_text());assert set(images)=={BASE+'assets/components/'+a['file'] for a in manifest['assets']},'image sitemap incomplete'
 inventory=json.loads((R/'docs/marketing/component-catalog.json').read_text());assert len(manifest['assets'])==inventory['counts']['publishedPreviewFiles']==142,'unique native image count mismatch';assert len(pages['components.html'].select('img'))==154 and inventory['counts']['nativeConsumerExamples']==6,'native consumer image usage count mismatch'
 marketing=json.loads((R/'docs/assets/marketing/manifest.json').read_text());assert marketing['source']['head_sha']==source['version'] and marketing['source']['run_id']==38157622095,'homepage images must share the current catalog capture source';assert len(marketing['assets'])==9,'eight native images plus overview required'
 assert inventory['nativeEvidence'].get('nativeJobsPassed')==23 and 'checksPassed' not in inventory['nativeEvidence'],'native workflow count must be23 verified jobs, not the PR aggregate'
 for name in ['README.md','docs/index.html','docs/components.html','docs/llms.txt','docs/marketing/proof.md']:
  raw=(R/name).read_text();assert '23 workflow jobs' in raw and '24 checks' not in raw,('native job count/parity',name)
 evidence_bytes=(R/'docs/marketing/native-capture-index.json').read_bytes()
 assert hashlib.sha256(evidence_bytes).hexdigest()=='d8a3318c1c2bcb825bcdfeb417abe68ceb9d484d0248be116077abc55a1be98a','unreviewed native evidence index'
 evidence=json.loads(evidence_bytes);records=evidence['records'];assert len(records)==510 and len({r['id'] for r in records})==510,'native evidence count/identity'
 assert dict(Counter(r['platform'] for r in records))=={'iphone':170,'ipad':170,'macos':170},'platform coverage'
 assert dict(Counter(r['kind'] for r in records))=={'isolated_component':360,'original_screen_family':108,'dedicated_text_field_state':42},'state-family coverage'
 rendered=[n for n in pages['components.html'].select('li') if 'data-capture-id' in n['attrs']]
 assert sorted(n['attrs']['data-capture-id'] for n in rendered)==sorted(r['id'] for r in records),'static evidence index incomplete'
 for a in manifest['assets']:
  matches=[r for r in records if r['capture']['sha256']==a['source']['sha256'] and r['artifact_id']==a['source']['artifact_id']]
  assert len(matches)==1 and matches[0]['component_id']==a['component_id'] and matches[0]['appearance']==a['appearance'],'hosted image not mapped to full evidence'
 for name in ['README.md','docs/llms.txt','docs/marketing/proof.md','docs/_config.yml','docs/marketing/component-catalog.json','docs/marketing/native-capture-index.json']:
  raw=(R/name).read_text()
  if name=='docs/_config.yml':raw=re.sub(r'(?ms)^exclude:\n.*?(?=^[a-zA-Z_]+:)', '', raw) # Exclusions are not public output.
  assert not re.search(r'\bluma\b|lu\.ma',raw,re.I),f'inspiration-brand content: {name}';assert 'separate from main' not in raw,'stale source availability';assert not re.search(r'42 (?:dedicated )?accessibility',raw,re.I),'incorrect capture category'
 assert 'does not enforce' in (R/'docs/robots.txt').read_text(),'robots project scope undisclosed'
 return {'template':'jangtrinh/design-os-github-page@d45be6a73af64ff7407d0a98dc3a3d980f00e05c','htmlPages':3,'matchingFAQAnswers':5,'hostedImages':142,'inventoriedCaptures':510,'sitemapRoutes':3,'limitations':['No search-engine submission or actual index visibility verified.','No ranking, rich-result, AEO/GEO eligibility or AI-citation guarantee.','Project-subpath robots.txt is not origin crawler policy.','llms.txt is a readability aid; it is not a special Google requirement.']}
if __name__=='__main__':
 try:print(json.dumps({'status':'passed',**validate()},indent=2))
 except (AssertionError,KeyError,ValueError,StopIteration,ET.ParseError) as e:print(json.dumps({'status':'failed','error':str(e)},indent=2));sys.exit(1)
