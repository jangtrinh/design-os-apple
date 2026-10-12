#!/usr/bin/env python3
"""Inspect actual Jekyll output for public marketing text and asset boundaries."""
import argparse,json,re,sys
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit,unquote
R=Path(__file__).resolve().parent.parent
FORBIDDEN=re.compile(r'\bluma\b|lu\.ma',re.I)
class Links(HTMLParser):
 def __init__(self,text):super().__init__();self.links=[];self.feed(text)
 def handle_starttag(self,tag,attrs):
  for key,value in attrs:
   if key in ('href','src') and value:self.links.append(value)
def validate(site):
 assert site.is_dir(),'Build output directory missing'
 files=list(site.rglob('*'));checked=0;binary=0
 required=['index.html','components.html','kit-architecture.html','llms.txt','sitemap.xml','assets/components/manifest.json']
 for name in required:assert (site/name).is_file(),'Missing built route: '+name
 allowed={}
 # Historical public specimens retain their existing rights notice and evidence links.
 legacy={
  "specimens/specimen-iphone17pro-compact.png":"9d61d18dad925c7d8723a09fd40ace8d99c30e1fa51c329cf512535d26210717",
  "specimens/specimen-iphone17pro-landscape.png":"a158da7780b61d45710c4f4bbce090ef0c54a33edf5d4148d41c450c4b21eb2d",
  "specimens/specimen-ipadpro-wide.png":"2ed549e7d66e4b6c4d3be95aea0c4738704deb591b1d5eb5051c6344c223292a"}
 for path,digest in legacy.items():
  if (site/path).exists():allowed[path]=digest
 for family in ['components','marketing']:
  manifest=json.loads((site/f'assets/{family}/manifest.json').read_text())
  for a in manifest['assets']:allowed[f'assets/{family}/'+a['file']]=a['sha256']
 import hashlib
 for p in files:
  if p.is_dir():continue
  rel=p.relative_to(site).as_posix();assert not p.is_symlink(),'Symlink in site: '+rel
  assert not FORBIDDEN.search(rel),'Reference-only path in site: '+rel
  raw=p.read_bytes()
  if p.suffix.lower() in {'.png','.webp','.jpg','.jpeg','.svg','.gif'}:assert rel in allowed,'Unadmitted image: '+rel
  if rel in allowed:assert hashlib.sha256(raw).hexdigest()==allowed[rel],'Unverified image bytes: '+rel
  try:text=raw.decode('utf-8')
  except UnicodeDecodeError:
   assert rel in allowed,'Unadmitted binary asset: '+rel
   binary+=1;continue
  assert not FORBIDDEN.search(text),'Reference-only text in site: '+rel
  if p.suffix=='.html':
   for value in Links(text).links:
    url=urlsplit(value)
    if url.scheme or url.netloc or not url.path:continue
    path=unquote(url.path)
    if path.startswith('/design-os-apple/'):target=site/path.removeprefix('/design-os-apple/')
    elif path.startswith('/'):target=site/path.lstrip('/')
    else:target=p.parent/path
    target=target.resolve();assert target.is_relative_to(site.resolve()),'Escaping site link: '+rel+' -> '+value
    if target.is_dir():target=target/'index.html'
    assert target.is_file(),'Broken built-site link: '+rel+' -> '+value
  checked+=1
 for rel in allowed:assert (site/rel).is_file(),'Missing admitted image: '+rel
 return {'status':'passed','textFiles':checked,'binaryFiles':binary,'admittedAssets':len(allowed),'limits':['Text and file admission checks do not OCR pixels. Native pixels are separately reviewed.']}
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--site',required=True,type=Path);p.add_argument('--output',type=Path);a=p.parse_args()
 try:result=validate(a.site)
 except (AssertionError,ValueError,OSError) as e:result={'status':'failed','error':str(e)}
 if a.output:a.output.write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result,indent=2));return result['status']!='passed'
if __name__=='__main__':sys.exit(main())
