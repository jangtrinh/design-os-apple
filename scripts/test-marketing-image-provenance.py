#!/usr/bin/env python3
"""Positive and adversarial controls for the reviewed marketing image boundary."""
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location("marketing", Path(__file__).with_name("verify-marketing-image-provenance.py"))
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
ROOT = Path(__file__).resolve().parent.parent


class MarketingImageTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="marketing-provenance-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.directory = self.root / MODULE.DIRECTORY
        shutil.copytree(ROOT / MODULE.DIRECTORY, self.directory)
        self.image = self.directory / "iphone-discovery-light.png"
        self.manifest = self.directory / "manifest.json"

    def rejected(self, reason):
        with self.assertRaisesRegex(ValueError, reason):
            MODULE.verify(self.root)

    def test_reviewed_set_passes(self):
        self.assertEqual(MODULE.verify(self.root), 9)

    def test_changed_image_bytes(self):
        data = bytearray(self.image.read_bytes())
        data[-1] ^= 1
        self.image.write_bytes(data)
        self.rejected("image hash mismatch")

    def test_changed_image_size(self):
        self.image.write_bytes(self.image.read_bytes() + b"extra")
        self.rejected("byte count mismatch")

    def test_missing_image(self):
        self.image.unlink()
        self.rejected("unexpected or missing")

    def test_extra_image(self):
        shutil.copyfile(self.image, self.directory / "unreviewed.png")
        self.rejected("unexpected or missing")

    def test_unexpected_nested_directory(self):
        (self.directory / "nested").mkdir()
        self.rejected("unexpected or missing")

    def test_symlink_image(self):
        self.image.unlink()
        self.image.symlink_to(ROOT / MODULE.DIRECTORY / self.image.name)
        self.rejected("nonregular")

    def test_symlink_directory(self):
        renamed = self.directory.with_name("renamed")
        self.directory.rename(renamed)
        self.directory.symlink_to(renamed, target_is_directory=True)
        self.rejected("symlinked marketing directory")

    def test_symlink_ancestor(self):
        assets = self.directory.parent
        renamed = assets.with_name("renamed")
        assets.rename(renamed)
        assets.symlink_to(renamed, target_is_directory=True)
        self.rejected("symlinked marketing ancestor")

    def test_symlink_manifest(self):
        self.manifest.unlink()
        self.manifest.symlink_to(ROOT / MODULE.DIRECTORY / "manifest.json")
        self.rejected("nonregular")

    def alter_manifest(self, change):
        manifest = json.loads(self.manifest.read_text())
        change(manifest)
        self.manifest.write_text(json.dumps(manifest))
        self.rejected("unreviewed provenance manifest")

    def test_changed_source_commit(self):
        self.alter_manifest(lambda data: data["source"].update(head_sha="0" * 40))

    def test_changed_ci_run(self):
        self.alter_manifest(lambda data: data["source"].update(run_id=1))

    def test_missing_provenance(self):
        self.alter_manifest(lambda data: data.pop("source"))

    def test_duplicate_asset(self):
        self.alter_manifest(lambda data: data["assets"].append(data["assets"][0]))

    def test_manifest_cannot_self_approve_image_change(self):
        import hashlib
        self.image.write_bytes(self.image.read_bytes() + b"extra")
        def update(data):
            asset = next(item for item in data["assets"] if item["file"] == self.image.name)
            asset.update(byte_size=self.image.stat().st_size, sha256=hashlib.sha256(self.image.read_bytes()).hexdigest())
        self.alter_manifest(update)


if __name__ == "__main__":
    unittest.main(verbosity=2)
