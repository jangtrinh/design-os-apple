#!/usr/bin/env python3
"""Discriminating red controls run against isolated copies, never the working tree."""
import copy
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import sys
sys.dont_write_bytecode = True
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('layered_gate', ROOT / 'scripts/verify-layered-kit.py')
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)

class LayeredKitControls(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='layered-kit-control-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for folder in ('Sources/DesignOSApple', 'Tests/DesignOSAppleTests', 'docs', 'design', 'Examples/LayeredKitPreview'):
            if (ROOT / folder).exists():
                shutil.copytree(ROOT / folder, self.root / folder)
        self.index = self.read('docs/layered-kit-index.json')
        self.coverage = self.read('docs/luma-kit-coverage.json')

    def read(self, path):
        return json.loads((self.root / path).read_text())

    def flush(self):
        (self.root / 'docs/layered-kit-index.json').write_text(json.dumps(self.index))
        (self.root / 'docs/luma-kit-coverage.json').write_text(json.dumps(self.coverage))

    def rejected(self, message):
        self.flush()
        with self.assertRaisesRegex(gate.Invalid, message):
            gate.verify(self.root)

    def source(self):
        return next(r for r in self.index['records'] if r['id'] == 'semantic/media-frame')

    def test_valid_baseline_is_not_native_or_screen_completion(self):
        result = gate.verify(self.root)
        self.assertEqual(result['research_mapped'], 393)
        self.assertEqual(result['native_tested_apis'], 0)
        self.assertEqual(result['exact_screen_states_source_verified'], 0)
        self.assertEqual(result['exact_screen_states_visual_reviewed'], 0)

    def recipe(self):
        return next(r for r in self.index['records'] if r['id'] == 'composite/form-section')

    def test_recipes_are_separate_from_public_apis(self):
        result = gate.verify(self.root)
        self.assertEqual(result['source_present_recipes'], 4)
        self.assertEqual(result['native_delegation_recipes'], 2)
        self.assertEqual(result['public_source_present_apis'], 49)
        self.assertEqual(result['source_present_records'], 56)
        self.assertEqual(result['exact_screen_states_source_verified'], 0)

    def test_recipe_requires_fixture(self):
        self.recipe()['compile_fixture'] = 'Tests/missing-recipe.swift'
        self.rejected('missing artifact')

    def test_recipe_requires_exact_fixture_function(self):
        self.recipe()['recipe']['fixture_function'] = 'imaginaryFixture'
        self.rejected('recipe fixture function missing')

    def test_recipe_requires_actual_native_call_in_named_function(self):
        record = self.recipe()
        path = self.root / record['compile_fixture']
        path.write_text(path.read_text() + '\nfunc fakeRecipe() { /* Section { Text("Not code") } */ }')
        record['recipe']['fixture_function'] = 'fakeRecipe'
        for linked in self.index['records']:
            if linked.get('compile_fixture') == record['compile_fixture'] and linked.get('source_status') == 'recipe_present':
                linked['compile_fixture_sha256'] = gate.sha(path)
        doc = self.root / record['documentation']
        doc.write_text(doc.read_text() + '\nfakeRecipe\n')
        self.rejected('recipe fixture does not call Form')

    def test_recipe_source_edit_invalidates_binding(self):
        path = self.root / self.recipe()['compile_fixture']
        path.write_text(path.read_text() + '\n// changed fixture\n')
        self.rejected('stale recipe fixture source')

    def test_recipe_cannot_claim_a_public_api(self):
        self.recipe()['source_status'] = 'source_present'
        self.recipe()['symbol'] = 'InventedFormSection'
        self.recipe()['visibility'] = 'public'
        self.rejected('recipe cannot be counted as a source API')

    def test_recipe_cannot_hide_source_api_metadata(self):
        self.recipe()['visibility'] = 'public'
        self.rejected('recipe is not a source API binding')

    def test_recipe_binding_cannot_omit_native_owner(self):
        self.recipe()['recipe']['bindings'] = []
        self.rejected('recipe native/existing bindings mismatch')

    def test_recipe_documentation_must_name_fixture(self):
        self.recipe()['documentation'] = 'docs/luma-layout-atlas.md'
        self.rejected('recipe documentation must name contract and fixture')

    def test_recipe_does_not_imply_native_execution(self):
        self.recipe()['native_status'] = 'passed'
        self.rejected('receipt required')

    def test_recipe_native_receipt_does_not_increment_api_counts(self):
        record = self.recipe()
        artifact = self.root / 'recipe-control.log'
        artifact.write_text('Synthetic evidence fixture for verifier testing only.\n')
        record['native_status'] = 'passed'
        record['evidence']['native_tested'] = {
            'result': 'passed', 'module_sha256': gate.module_digest(self.root),
            'source_revision': 'b' * 40, 'platform': 'macOS',
            'command': 'swift test (synthetic recipe control)', 'toolchain': 'Synthetic toolchain',
            'artifact': 'recipe-control.log', 'artifact_sha256': gate.sha(artifact),
            'compile_fixture': record['compile_fixture'],
            'compile_fixture_sha256': gate.sha(self.root / record['compile_fixture']),
        }
        self.flush()
        result = gate.verify(self.root)
        self.assertEqual(result['native_tested_recipes'], 1)
        self.assertEqual(result['native_tested_apis'], 0)
        self.assertEqual(result['exact_screen_states_native_tested'], 0)

    def test_visual_receipts_bind_fixture_even_after_native_receipt_refresh(self):
        baseline = copy.deepcopy(self.index)
        for rid in ('semantic/media-frame', 'composite/form-section'):
            with self.subTest(record=rid):
                self.index = copy.deepcopy(baseline)
                record = next(r for r in self.index['records'] if r['id'] == rid)
                fixture = self.root / record['compile_fixture']
                original = fixture.read_text()
                artifact = self.root / 'visual-control.log'
                artifact.write_text('Synthetic evidence fixture only.\n')
                capture = self.root / 'visual-control.png'
                capture.write_bytes(b'Synthetic capture bytes for structural verifier test only.')
                native = {
                    'result': 'passed', 'module_sha256': gate.module_digest(self.root),
                    'source_revision': 'c' * 40, 'platform': 'macOS',
                    'command': 'swift test (synthetic visual control)', 'toolchain': 'Synthetic toolchain',
                    'artifact': 'visual-control.log', 'artifact_sha256': gate.sha(artifact),
                    'compile_fixture': record['compile_fixture'], 'compile_fixture_sha256': gate.sha(fixture),
                }
                visual = dict(native, reviewer='Synthetic reviewer', appearance='light', window='800x600',
                              variant_id='synthetic-control', capture='visual-control.png', capture_sha256=gate.sha(capture))
                record.update(native_status='passed', visual_status='reviewed',
                              evidence=dict(native_tested=native, visual_reviewed=visual))
                self.flush()
                gate.verify(self.root)
                try:
                    fixture.write_text(original + '\n// Fixture-only change\n')
                    for linked in self.index['records']:
                        if linked.get('compile_fixture') == record['compile_fixture'] and linked['source_status'] == 'recipe_present':
                            linked['compile_fixture_sha256'] = gate.sha(fixture)
                    native['compile_fixture_sha256'] = gate.sha(fixture)
                    self.rejected('stale visual compile fixture')
                finally:
                    fixture.write_text(original)
        self.index = baseline

    def test_missing_screen(self):
        self.coverage['screens'].pop()
        self.rejected('missing or unknown source IDs')

    def test_duplicate_screen(self):
        self.coverage['screens'].append(copy.deepcopy(self.coverage['screens'][0]))
        self.rejected('duplicate')

    def test_unknown_screen(self):
        self.coverage['screens'][0]['source_screen_id'] = 'unknown'
        self.rejected('missing or unknown source IDs')

    def test_wrong_source_hash(self):
        self.coverage['screens'][0]['source_asset_sha256'] = '0' * 64
        self.rejected('invalid source hash')

    def test_changed_inventory(self):
        path = self.root / 'docs/luma-layout-atlas.inventory.json'
        path.write_text(path.read_text() + '\n')
        self.rejected('stale inventory source hash')

    def test_missing_variant(self):
        self.coverage['screens'][0]['observed']['variant_id'] = ''
        self.rejected('state variant')

    def test_unknown_screen_dependency(self):
        self.coverage['screens'][0]['proposed_reconstruction']['shell_id'] = 'shell/missing'
        self.rejected('unknown or mistyped reference')

    def test_wrong_dependency_type(self):
        self.coverage['screens'][0]['proposed_reconstruction']['shell_id'] = 'semantic/avatar'
        self.rejected('unknown or mistyped reference')

    def test_unexplained_family_override(self):
        self.coverage['screens'][0]['proposed_reconstruction']['basis'] = ''
        self.rejected('unexplained family mapping')

    def test_duplicate_registry_id(self):
        self.index['records'].append(copy.deepcopy(self.index['records'][0]))
        self.rejected('duplicate')

    def test_unregistered_contract(self):
        self.index['records'] = [r for r in self.index['records'] if r['id'] != 'semantic/avatar']
        self.rejected('unregistered proposed dependency')

    def test_unknown_layer_dependency(self):
        self.source()['dependencies'].append('primitive/missing')
        self.rejected('unknown reference')

    def test_upward_declared_dependency(self):
        self.source()['dependencies'].append('screen/media-detail')
        self.rejected('upward dependency')

    def test_dependency_cycle(self):
        self.source()['dependencies'].append('semantic/media-frame')
        self.rejected('dependency cycle')

    def test_missing_source(self):
        (self.root / self.source()['source']).unlink()
        self.rejected('missing artifact')

    def test_stale_source_hash(self):
        path = self.root / self.source()['source']
        path.write_text(path.read_text() + '\n// source changed\n')
        self.rejected('stale source hash')

    def test_unsafe_path(self):
        self.source()['source'] = '../outside.swift'
        self.rejected('unsafe path')

    def test_fabricated_symbol(self):
        self.source()['symbol'] = 'ImaginaryAPI'
        self.rejected('missing actual API declaration')

    def test_recursive_orphan_file(self):
        path = self.root / gate.ROOTS['semantic'] / 'Nested/Orphan.swift'
        path.parent.mkdir()
        path.write_text('public struct Orphan {}')
        self.rejected('orphan Swift file')

    def test_public_symbol_added_to_registered_file(self):
        record = self.source()
        path = self.root / record['source']
        path.write_text(path.read_text() + '\npublic struct UnregisteredPublicAPI {}\n')
        record['source_sha256'] = gate.sha(path)
        self.rejected('unregistered public symbol')

    def test_source_upward_reference_even_without_declared_edge(self):
        record = self.source()
        path = self.root / record['source']
        path.write_text(path.read_text() + '\nprivate typealias Upward = DesignOSMediaDetailScreen\n')
        record['source_sha256'] = gate.sha(path)
        self.rejected('source reaches upward')

    def test_app_import(self):
        record = self.source()
        path = self.root / record['source']
        path.write_text(path.read_text() + '\nimport CalorieCamCore\n')
        record['source_sha256'] = gate.sha(path)
        self.rejected('consuming-app import')

    def test_missing_compile_fixture(self):
        self.source()['compile_fixture'] = 'Tests/does-not-exist.swift'
        self.rejected('missing artifact')

    def test_marker_only_api(self):
        record = self.source()
        path = self.root / record['source']
        path.write_text('public enum DesignOSMediaFrame {}')
        record['source_sha256'] = gate.sha(path)
        record['public_declarations'] = gate.declarations(path.read_text())
        self.rejected('marker-only API')

    def test_empty_body_is_not_implementation(self):
        record = self.source()
        path = self.root / record['source']
        path.write_text('public struct DesignOSMediaFrame: View { public var body: some View { EmptyView() } }')
        record['source_sha256'] = gate.sha(path)
        record['public_declarations'] = gate.declarations(path.read_text())
        self.rejected('placeholder EmptyView body')

    def test_comment_is_not_compile_fixture(self):
        record = self.source()
        path = self.root / 'Tests/fake-fixture.swift'
        path.write_text('// DesignOSMediaFrame { Text("Comment only") }')
        record['compile_fixture'] = 'Tests/fake-fixture.swift'
        self.rejected('compile fixture does not exercise API')

    def test_provider_boundary_cannot_be_called_kit_implementation(self):
        record = next(r for r in self.index['records'] if r['id'] == 'screen/provider-host')
        record['ownership'] = 'kit'
        self.rejected('provider boundary misrepresented')

    def test_false_native_pass(self):
        self.source()['native_status'] = 'passed'
        self.rejected('receipt required')

    def test_false_visual_pass(self):
        self.source()['visual_status'] = 'reviewed'
        self.rejected('visual pass without native test')

    def test_false_exact_state_pass(self):
        self.coverage['screens'][0]['status']['screen_state_implementation'] = 'implemented'
        self.rejected('unsupported exact-state implementation claim')

    def test_false_aggregate_pass(self):
        self.coverage['coverage']['screen_states_native_runtime_tested'] = 393
        self.rejected('false coverage aggregate')

    def test_missing_ownership_boundary(self):
        self.source()['boundary'] = ''
        self.rejected('explicit boundary required')

    def test_modified_frozen_authority(self):
        path = self.root / 'design/design.tokens.json'
        path.write_text(path.read_text() + '\n')
        self.rejected('frozen authority changed')

    def test_frozen_authority_cannot_be_resealed(self):
        path = self.root / 'design/design.tokens.json'
        path.write_text(path.read_text() + '\n')
        self.index['frozen_sha256']['design/design.tokens.json'] = gate.sha(path)
        self.rejected('frozen authority pins changed')

    def test_native_receipt_is_source_bound_and_does_not_complete_screens(self):
        record = self.source()
        artifact = self.root / 'native-test.log'
        artifact.write_text('Synthetic verifier fixture only. This is not real native execution.\n')
        record['native_status'] = 'passed'
        record['evidence']['native_tested'] = {
            'result': 'passed', 'module_sha256': gate.module_digest(self.root),
            'source_revision': 'a' * 40, 'platform': 'macOS',
            'command': 'swift test (synthetic control)', 'toolchain': 'Synthetic test toolchain',
            'artifact': 'native-test.log', 'artifact_sha256': gate.sha(artifact),
            'compile_fixture': record['compile_fixture'],
            'compile_fixture_sha256': gate.sha(self.root / record['compile_fixture']),
        }
        self.flush()
        result = gate.verify(self.root)
        self.assertEqual(result['native_tested_apis'], 1)
        self.assertEqual(result['exact_screen_states_native_tested'], 0)
        fixture = self.root / record['compile_fixture']
        original_fixture = fixture.read_text()
        fixture.write_text(original_fixture + '\n// Changed test source\n')
        self.rejected('stale native compile fixture')
        fixture.write_text(original_fixture)
        # Even a source change outside the API invalidates the module-bound receipt.
        path = self.root / 'Sources/DesignOSApple/Changed.swift'
        path.write_text('// New module source\n')
        self.rejected('stale module source digest')

if __name__ == '__main__':
    unittest.main(verbosity=2)
