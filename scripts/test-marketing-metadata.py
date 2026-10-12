#!/usr/bin/env python3
"""Negative controls for factual marketing metadata; stdlib only, no network."""
import importlib.util,json,shutil,tempfile,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parent.parent
spec=importlib.util.spec_from_file_location('metadata',ROOT/'scripts/verify-marketing-metadata.py');guard=importlib.util.module_from_spec(spec);spec.loader.exec_module(guard)
FILES=['README.md','docs/index.html','docs/components.html','docs/kit-architecture.html','docs/sitemap.xml','docs/robots.txt','docs/llms.txt','docs/_config.yml','docs/marketing/proof.md','docs/marketing/component-catalog.json','docs/assets/components/manifest.json','docs/marketing/native-capture-index.json']
class MetadataControls(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory();self.root=Path(self.temp.name);self.original=guard.R;guard.R=self.root
  for name in FILES:
   p=self.root/name;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/name,p)
 def tearDown(self):guard.R=self.original;self.temp.cleanup()
 def reject(self,name,before,after):
  p=self.root/name;s=p.read_text();self.assertIn(before,s);p.write_text(s.replace(before,after,1))
  with self.assertRaises((AssertionError,ValueError,KeyError,StopIteration)):guard.validate()
 def test_valid(self):self.assertEqual(guard.validate()['hostedImages'],142)
 def test_wrong_canonical(self):self.reject('docs/components.html','rel="canonical" href="https://jangtrinh.github.io/design-os-apple/components.html"','rel="canonical" href="https://example.com/"')
 def test_hidden_from_search(self):self.reject('docs/index.html','content="index, follow','content="noindex, follow')
 def test_raw_brand_url(self):self.reject('docs/llms.txt','# Apple Design OS','# Apple Design OS\nhttps://example.com/luma-reference')
 def test_false_source_version(self):self.reject('docs/index.html','"version": "1898ce28861d642f57dccd88fd57afcbe3be5bb9"','"version": "1.0.0"')
 def test_readme_faq_drift(self):self.reject('README.md','Yes. The layered kit was merged','No. The layered kit was merged')
 def test_sitemap_image_omission(self):
  p=self.root/'docs/sitemap.xml';s=p.read_text();import re;p.write_text(re.sub(r'<image:image>.*?</image:image>','',s,count=1))
  with self.assertRaises(AssertionError):guard.validate()
 def test_capture_index_mutation(self):self.reject('docs/marketing/native-capture-index.json','"capture_count": 510','"capture_count": 511')
 def test_missing_alt(self):self.reject('docs/components.html','alt="','data-old-alt="')
 def test_stale_availability(self):self.reject('docs/llms.txt','# Apple Design OS','# Apple Design OS\nThe kit is separate from main.')
 def test_false_capture_category(self):self.reject('docs/llms.txt','# Apple Design OS','# Apple Design OS\n42 accessibility states')
if __name__=='__main__':unittest.main()
