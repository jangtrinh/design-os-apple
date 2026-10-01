#!/usr/bin/env python3
"""Red-probe automated test suite for verify-ukmc-corpus.py.

Verifies that the strict verifier fails closed when presented with corrupted or non-compliant artifacts:
1. Tampered source_attribution SHA256.
2. Missing captured_at timestamp.
3. Empty 'when' routing tags array.
4. Dangling entity relationship (pointing to non-existent unit ID).
5. Mismatched secondary <!-- ease:source ... --> anchor.
6. Disallowed relationship type.
"""

import importlib.util
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

# Prevent bytecode caching into repository publication boundaries
sys.dont_write_bytecode = True

REPO_ROOT = Path(__file__).resolve().parent.parent
verifier_path = REPO_ROOT / "scripts" / "verify-ukmc-corpus.py"
spec = importlib.util.spec_from_file_location("verify_ukmc_corpus", verifier_path)
verify_mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verify_mod)
verify_corpus_and_units = verify_mod.verify_corpus_and_units


class TestUKMCVerifierProbes(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = Path(__file__).resolve().parent.parent

    def setUp(self):
        self.temp_dir = Path(tempfile.mkdtemp(prefix="ukmc-probe-"))
        # Clone docs structure
        shutil.copytree(self.repo_root / "docs", self.temp_dir / "docs")

    def tearDown(self):
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def test_baseline_clean_passes(self):
        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertEqual(len(errors), 0, f"Baseline should pass cleanly: {errors}")

    def test_tampered_sha_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "iphone-duo-hardware-and-postures.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace("4fb160f316988bf1ef823f3d2dd40c6688e5f96c8afac49c1e4ac8f0e92eab2a", "0000000000000000000000000000000000000000000000000000000000000000")
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("does not match corpus" in e or "anchor sha256" in e for e in errors), f"Should fail tampered SHA: {errors}")

    def test_missing_timestamp_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "ios27-adaptive-multitasking-and-splitview.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('captured_at: "2026-10-01T08:24:26Z"', 'captured_at: ""')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("missing or empty 'captured_at'" in e for e in errors), f"Should fail missing captured_at: {errors}")

    def test_empty_when_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "macos27-appkit-menu-and-navigation-evolution.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('when: ["macos27", "appkit", "menu-visibility", "preferredImageVisibility", "tabs-role", "nsrefreshcontroller"]', 'when: []')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("non-empty list" in e or "at least one tag" in e for e in errors), f"Should fail empty when: {errors}")

    def test_dangling_relationship_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "swiftui-os27-navigation-and-input-updates.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('id: "ios27-adaptive-multitasking-and-splitview"', 'id: "non-existent-unit-xyz"')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("non-existent unit id" in e for e in errors), f"Should fail dangling relationship: {errors}")

    def test_mismatched_second_anchor_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "iphone-duo-hardware-and-postures.md"
        content = target.read_text(encoding="utf-8")
        # Tamper the second anchor (Newsroom anchor)
        corrupted = content.replace('sha256="f90367a10319b84e71d0333396394db65bbc2d99a92ae06f98b91b05a2829eed"', 'sha256="1111111111111111111111111111111111111111111111111111111111111111"')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("does not match corpus" in e for e in errors), f"Should fail mismatched second anchor: {errors}")

    def test_unknown_relationship_type_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "iphone-duo-hardware-and-postures.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('relationship: "extends"', 'relationship: "unsupported_parent_child"')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("Invalid relationship type" in e for e in errors), f"Should fail invalid relationship: {errors}")

    def test_invalid_captured_at_timestamp_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "ios27-adaptive-multitasking-and-splitview.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('captured_at: "2026-10-01T08:24:26Z"', 'captured_at: "invalid"')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("not a valid ISO 8601 aware timestamp" in e for e in errors), f"Should fail invalid timestamp: {errors}")

    def test_invalid_quarantine_bool_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "iphone-duo-hardware-and-postures.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('is_external_untrusted: false', 'is_external_untrusted: invalid')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("must be an actual boolean" in e for e in errors), f"Should fail non-boolean quarantine: {errors}")

    def test_invalid_modality_enum_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "macos27-appkit-menu-and-navigation-evolution.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('modality: "web"', 'modality: "invalid"')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("invalid modality 'invalid'" in e for e in errors), f"Should fail invalid modality: {errors}")

    def test_invalid_trust_tier_enum_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "swiftui-os27-navigation-and-input-updates.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace('trust_tier: "verified"', 'trust_tier: "invalid"')
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("invalid trust_tier 'invalid'" in e for e in errors), f"Should fail invalid trust_tier: {errors}")

    def test_mismatched_anchor_timestamp_fails(self):
        target = self.temp_dir / "docs" / "knowledge" / "ios27-adaptive-multitasking-and-splitview.md"
        content = target.read_text(encoding="utf-8")
        corrupted = content.replace(
            'captured="2026-10-01T08:24:26Z"',
            'captured="2026-01-01T00:00:00Z"'
        )
        target.write_text(corrupted, encoding="utf-8")

        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("does not match corpus manifest timestamp" in e for e in errors), f"Should fail mismatched timestamp: {errors}")

    def test_check_only_leaves_artifacts_unchanged(self):
        strict_index = self.temp_dir / "docs" / "knowledge" / "index.strict.json"
        # First ensure index is clean and in sync
        errors_write = verify_corpus_and_units(self.temp_dir, check_only=False)
        self.assertEqual(len(errors_write), 0)

        orig_mtime = strict_index.stat().st_mtime_ns
        orig_content = strict_index.read_text(encoding="utf-8")

        # In check_only mode, index.strict.json must NOT be rewritten or modified
        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertEqual(len(errors), 0)
        self.assertEqual(strict_index.read_text(encoding="utf-8"), orig_content)
        self.assertEqual(strict_index.stat().st_mtime_ns, orig_mtime)

        # In check_only mode, missing index must fail
        strict_index.unlink()
        errors_missing = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("index missing" in e.lower() for e in errors_missing))

    def test_stale_index_fails_in_check_mode(self):
        strict_index = self.temp_dir / "docs" / "knowledge" / "index.strict.json"
        # Ensure initial index is generated
        errors_write = verify_corpus_and_units(self.temp_dir, check_only=False)
        self.assertEqual(len(errors_write), 0)

        # Tamper one unit's file_sha256 in index.strict.json
        index_data = json.loads(strict_index.read_text(encoding="utf-8"))
        index_data[0]["file_sha256"] = "0000000000000000000000000000000000000000000000000000000000000000"
        strict_index.write_text(json.dumps(index_data, indent=2) + "\n", encoding="utf-8")

        # Check mode must detect stale index
        errors = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertTrue(any("stale file_sha256" in e or "mismatch" in e for e in errors), f"Should fail stale index: {errors}")

        # Write mode must heal/regenerate the index cleanly
        errors_heal = verify_corpus_and_units(self.temp_dir, check_only=False)
        self.assertEqual(len(errors_heal), 0)

        # After healing, check mode passes again
        errors_check = verify_corpus_and_units(self.temp_dir, check_only=True)
        self.assertEqual(len(errors_check), 0)

    def test_missing_canonical_builder_fails_closed_unless_declared(self):
        orig_state = verify_mod.HAS_CANONICAL_BUILDER
        try:
            verify_mod.HAS_CANONICAL_BUILDER = False
            # Fails closed without --allow-fallback
            errors = verify_corpus_and_units(self.temp_dir, check_only=True, allow_fallback=False)
            self.assertTrue(any("Canonical knowledge-builder contract not found" in e for e in errors))

            # Passes with allow_fallback=True
            errors_fallback = verify_corpus_and_units(self.temp_dir, check_only=True, allow_fallback=True)
            self.assertEqual(len(errors_fallback), 0)
        finally:
            verify_mod.HAS_CANONICAL_BUILDER = orig_state


if __name__ == "__main__":
    unittest.main()
