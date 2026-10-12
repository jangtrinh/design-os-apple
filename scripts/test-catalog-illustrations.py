#!/usr/bin/env python3
"""Source-value and evidence-boundary controls for explanatory catalog visuals."""
import hashlib,importlib.util,json,subprocess,sys,unittest
from pathlib import Path
from xml.etree import ElementTree as ET
R=Path(__file__).resolve().parent.parent
spec=importlib.util.spec_from_file_location('catalog',R/'scripts/generate-component-catalog.py');catalog=importlib.util.module_from_spec(spec);spec.loader.exec_module(catalog)
class IllustrationControls(unittest.TestCase):
 def test_all_source_entries_mapped(self):
  data=json.loads((R/'docs/marketing/component-catalog.json').read_text());manifest=json.loads((R/'docs/assets/illustrations/manifest.json').read_text());assets=manifest['assets'];missing=[i for g in data['groups'] for i in g['items'] if not i.get('preview')]
  self.assertEqual(len(assets),28);self.assertEqual({a['entryId'] for a in assets},{i['id'] for i in missing});self.assertEqual(manifest['sourceCommit'],data['sourceCommit'])
  for a in assets:
   path=R/'docs/assets/illustrations'/a['file'];raw=path.read_bytes();self.assertEqual(hashlib.sha256(raw).hexdigest(),a['sha256']);svg=ET.fromstring(raw)
   self.assertEqual(svg.tag,'{http://www.w3.org/2000/svg}svg');self.assertEqual(int(svg.attrib['width']),a['width']);self.assertEqual(int(svg.attrib['height']),a['height'])
   text=' '.join(svg.itertext());self.assertIn(a['label'],text);self.assertRegex(text.lower(),r'not a native (screenshot|capture)')
   for n in svg.iter():
    self.assertNotIn(n.tag.split('}')[-1],['script','foreignObject','image'])
    for key,val in n.attrib.items():self.assertFalse(key.lower().startswith('on'));self.assertNotIn('href',key.lower())
 def test_alias_resolution(self):self.assertEqual(catalog.resolved_token('{b}',{'a':'#123456','b':'{a}'}),'#123456')
 def test_missing_alias_rejected(self):
  with self.assertRaises(ValueError):catalog.resolved_token('{absent}',{})
 def test_cyclic_alias_rejected(self):
  with self.assertRaises(ValueError):catalog.resolved_token('{a}',{'a':'{b}','b':'{a}'})
 def test_all_token_values_visualized(self):
  data=json.loads((R/'docs/marketing/component-catalog.json').read_text());lookup={t['path']:t['value'] for t in data['tokens']};self.assertEqual(len(lookup),160)
  for token in data['tokens']:
   result=catalog.token_visual(token,lookup);self.assertIn('data-token-visual="'+token['id']+'"',result);self.assertIn('Web illustration',result);self.assertNotIn('background:{',result)
 def test_token_raw_alias_preserved(self):
  data=json.loads((R/'docs/marketing/component-catalog.json').read_text());tokens=[t for t in data['tokens'] if t['type']=='color' and str(t['value']).startswith('{')];self.assertEqual(len(tokens),40)
 def test_native_asset_count_unchanged(self):self.assertEqual(len(json.loads((R/'docs/assets/components/manifest.json').read_text())['assets']),142)
if __name__=='__main__':unittest.main()
