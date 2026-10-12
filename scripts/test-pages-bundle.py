#!/usr/bin/env python3
"""Positive and rejection controls for the actual Pages output boundary."""
import importlib.util,json,hashlib,tempfile,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('bundle',Path(__file__).with_name('verify-pages-bundle.py'));guard=importlib.util.module_from_spec(spec);spec.loader.exec_module(guard)
class BundleControls(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
  for path in ['index.html','components.html','kit-architecture.html','llms.txt','sitemap.xml']:(self.root/path).write_text('Native kit')
  for family in ['components','marketing','illustrations']:
   d=self.root/'assets'/family;d.mkdir(parents=True);raw=b'\x89PNG\xfffixture';(d/'approved.png').write_bytes(raw);(d/'manifest.json').write_text(json.dumps({'assets':[{'file':'approved.png','sha256':hashlib.sha256(raw).hexdigest()}]}))
 def tearDown(self):self.tmp.cleanup()
 def test_valid(self):self.assertEqual(guard.validate(self.root)['admittedAssets'],3)
 def reject(self,path,raw):
  (self.root/path).write_bytes(raw)
  with self.assertRaises(AssertionError):guard.validate(self.root)
 def test_forbidden_text(self):self.reject('index.html',b'Luma reference')
 def test_forbidden_path(self):self.reject('luma-notes.html',b'Neutral visible title')
 def test_unadmitted_binary(self):self.reject('unreviewed.png',b'\xffPNG')
 def test_asset_mutation(self):self.reject('assets/components/approved.png',b'\xffchanged')
 def test_missing_link(self):self.reject('index.html',b'<a href="excluded-reference.html">Reference</a>')
 def test_missing_route(self):
  (self.root/'components.html').unlink()
  with self.assertRaises(AssertionError):guard.validate(self.root)
 def test_missing_asset(self):
  (self.root/'assets/components/approved.png').unlink()
  with self.assertRaises(AssertionError):guard.validate(self.root)
if __name__=='__main__':unittest.main()
