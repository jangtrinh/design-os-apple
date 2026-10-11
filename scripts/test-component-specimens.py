#!/usr/bin/env python3
"""Portable fixture-binding red controls; these do not compile Swift or certify AX."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ComponentSpecimenControls(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='component-specimen-control-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.manifest_path = self.root / 'docs/component-native-specimen-manifest.json'
        self.manifest = json.loads((ROOT / 'docs/component-native-specimen-manifest.json').read_text())
        paths = {record['source'] for record in self.manifest['records']}
        paths.update(('scripts/verify-component-specimens.py',
                      'docs/component-native-specimen-manifest.json',
                      self.manifest['fixture_source'], self.manifest['capture_test_source']))
        for relative in paths:
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / relative, target)
        self.source = self.root / self.manifest['fixture_source']
        self.tests = self.root / self.manifest['capture_test_source']

    def refresh_fixture_hashes(self):
        for source_key, hash_key in (('fixture_source', 'fixture_source_sha256'),
                                     ('capture_test_source', 'capture_test_source_sha256')):
            self.manifest[hash_key] = hashlib.sha256((self.root / self.manifest[source_key]).read_bytes()).hexdigest()
        self.manifest_path.write_text(json.dumps(self.manifest))

    def check(self, error=None):
        result = subprocess.run([sys.executable, str(self.root / 'scripts/verify-component-specimens.py')],
                                capture_output=True, text=True, timeout=10)
        if error is None:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn('120 planned captures per target', result.stdout)
        else:
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(error, result.stderr)

    def test_bound_baseline_keeps_native_execution_separate(self):
        self.check()

    def test_read_only_contrast_observation_is_allowed(self):
        self.source.write_text(self.source.read_text() + '\nstruct ContrastReadControl {\n'
                               '    @Environment(\\.colorSchemeContrast) private var contrast\n}\n')
        self.refresh_fixture_hashes()
        self.check()

    def test_contrast_environment_setters_are_rejected(self):
        original = self.source.read_text()
        mutations = [
            '.environment(\\.colorSchemeContrast, .increased)',
            '.environment ( \\.colorSchemeContrast , .standard )',
            '.environment(\n    \\.colorSchemeContrast,\n    .increased\n)',
            '.transformEnvironment(\\.colorSchemeContrast) { $0 = .increased }',
        ]
        for mutation in mutations:
            with self.subTest(mutation=mutation):
                self.source.write_text(original + '\n' + mutation + '\n')
                self.refresh_fixture_hashes()
                self.check('Contrast requires the actual platform setting')

    def test_diagnostic_attachment_cannot_use_reserved_capture_namespace(self):
        original = self.tests.read_text()
        assignment = 'diagnostic.name = "diagnostics--backdrop-policy-inputs--" +'
        self.assertIn(assignment, original)
        for mutation in ('diagnostic.name = "component--backdrop-policy-inputs--" +',
                         'diagnostic.name = stem + "--backdrop-policy-inputs" +'):
            with self.subTest(mutation=mutation):
                self.tests.write_text(original.replace(assignment, mutation, 1))
                self.refresh_fixture_hashes()
                self.check('Backdrop diagnostics must stay outside the reserved component capture namespace')

    def test_unsupported_contrast_capture_still_rejected(self):
        self.tests.write_text(self.tests.read_text() + '\ntry capture("semantic/media-backdrop", state: "increased-contrast", appearance: "dark")\n')
        self.refresh_fixture_hashes()
        self.check('Unsupported contrast capture must not be claimed')

    def test_unsupported_contrast_manifest_case_still_rejected(self):
        self.manifest['records'][0]['capture_cases'].append({'state': 'increased-contrast', 'appearance': 'dark'})
        self.manifest['planned_capture_count_per_target'] += 1
        self.refresh_fixture_hashes()
        self.check('Unsupported contrast capture case must not be claimed')

    def test_stale_fixture_hash_still_rejected(self):
        self.source.write_text(self.source.read_text() + '\n// stale fixture\n')
        self.check('Stale fixture source hash')

    def test_stale_capture_hash_still_rejected(self):
        self.tests.write_text(self.tests.read_text() + '\n// stale capture\n')
        self.check('Stale capture test hash')

    def test_forced_focus_still_rejected(self):
        self.source.write_text(self.source.read_text() + '\n.focused($focus)\n')
        self.refresh_fixture_hashes()
        self.check('Fixtures must not force native focus')

    def test_execution_claim_still_rejected(self):
        self.manifest['records'][0]['native_status'] = 'passed'
        self.refresh_fixture_hashes()
        self.check('Planned fixture manifest must not masquerade as executed evidence')


if __name__ == '__main__':
    unittest.main()
