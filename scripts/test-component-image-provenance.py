#!/usr/bin/env python3
"""Positive and adversarial controls for the reviewed component image boundary."""
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import sys
import unittest

sys.dont_write_bytecode = True

SPEC = importlib.util.spec_from_file_location("component", Path(__file__).with_name("verify-component-image-provenance.py"))
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
ROOT = Path(__file__).resolve().parent.parent


class ComponentImageTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="component-provenance-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.directory = self.root / MODULE.DIRECTORY
        shutil.copytree(ROOT / MODULE.DIRECTORY, self.directory)
        self.image = self.directory / "iphone-discovery-light.webp"
        self.manifest = self.directory / "manifest.json"

    def rejected(self, reason):
        with self.assertRaisesRegex(ValueError, reason):
            MODULE.verify(self.root)

    def test_reviewed_set_passes(self):
        self.assertEqual(MODULE.verify(self.root), 142)

    def test_changed_image_bytes(self):
        data = bytearray(self.image.read_bytes())
        data[-1] ^= 1
        self.image.write_bytes(data)
        self.rejected("hash mismatch")

    def test_changed_image_size(self):
        self.image.write_bytes(self.image.read_bytes() + b"extra")
        self.rejected("invalid byte size")

    def test_missing_image(self):
        self.image.unlink()
        self.rejected("unexpected or missing")

    def test_extra_image(self):
        shutil.copyfile(self.image, self.directory / "unreviewed.webp")
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
        self.rejected("symlinked component image directory")

    def test_symlink_ancestor(self):
        assets = self.directory.parent
        renamed = assets.with_name("renamed")
        assets.rename(renamed)
        assets.symlink_to(renamed, target_is_directory=True)
        self.rejected("symlinked component image directory")

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


    def test_changed_isolated_image_bytes(self):
        image = self.directory / 'iphone-semantic-avatar-light.webp'
        data = bytearray(image.read_bytes())
        data[-1] ^= 1
        image.write_bytes(data)
        self.rejected('hash mismatch')

    def test_changed_binding_hash(self):
        self.alter_manifest(lambda data: data['assets'][0]['source'].update(binding_sha256='0' * 64))

    def test_changed_component_mapping(self):
        self.alter_manifest(lambda data: data['assets'][0].update(component_id='semantic/avatar'))

    def test_changed_state(self):
        self.alter_manifest(lambda data: data['assets'][0].update(state='error'))

    def test_changed_platform(self):
        self.alter_manifest(lambda data: data['assets'][0].update(platform='macOS'))

    def test_added_reference_metadata(self):
        self.alter_manifest(lambda data: data['assets'][0].update(reference_image='reference.png'))

    def test_relabelled_transform(self):
        self.alter_manifest(lambda data: data['assets'][0]['transform'].update(scale=0.5))

    def test_extra_private_capture_index(self):
        (self.directory / 'capture-index.json').write_text('{}')
        self.rejected('unexpected or missing')

    def test_extra_component_route_is_not_admitted(self):
        shutil.copyfile(self.image, self.directory / 'iphone-semantic-unreviewed-light.webp')
        self.rejected('unexpected or missing')


    def test_changed_crop_coordinates(self):
        def change(data):
            asset = next(a for a in data['assets'] if a['component_id'] == 'semantic/avatar')
            asset['transform']['crop'][3] -= 1
        self.alter_manifest(change)

    def test_fabricated_screen_binding(self):
        def change(data):
            asset = next(a for a in data['assets'] if a['scope'] == 'screen-family')
            asset['source']['binding'] = {'raw': {'visual_review': 'passed'}}
        self.alter_manifest(change)

    def test_rewritten_emitted_visual_review(self):
        def change(data):
            asset = next(a for a in data['assets'] if a['scope'] == 'isolated-component')
            asset['source']['binding']['raw']['visual_review'] = 'passed'
        self.alter_manifest(change)


if __name__ == "__main__":
    unittest.main(verbosity=2)
