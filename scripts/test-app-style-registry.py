#!/usr/bin/env python3
"""Portable adversarial tests for app-style discovery; no native execution."""

import copy
import importlib.util
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location("app_style_registry", ROOT / "scripts/verify-app-style-registry.py")
REGISTRY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(REGISTRY)
BASE = json.loads((ROOT / REGISTRY.DEFAULT_MANIFEST).read_text(encoding="utf-8"))


class AppStyleIndexTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="app-style-index-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name) / "repo"
        self.root.mkdir()
        paths = {
            "Package.swift", REGISTRY.DEFAULT_MANIFEST, BASE["runtime"]["source"],
            *BASE["documentation"].values(),
            *(component["source"] for component in BASE["components"]),
            *BASE["verification"]["sourceTests"],
            *BASE["verification"]["nativeCommands"],
        }
        for relative in paths:
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / relative, target)
        self.data = copy.deepcopy(BASE)

    def write(self):
        (self.root / REGISTRY.DEFAULT_MANIFEST).write_text(json.dumps(self.data), encoding="utf-8")

    def reject(self, message):
        self.write()
        with self.assertRaisesRegex(REGISTRY.IndexError, message):
            REGISTRY.validate(self.root)

    def alter_source(self, relative, old, new):
        path = self.root / relative
        text = path.read_text(encoding="utf-8")
        self.assertIn(old, text)
        path.write_text(text.replace(old, new), encoding="utf-8")

    def test_valid_index(self):
        result = REGISTRY.validate(self.root)
        self.assertEqual(result["id"], "editorial")
        self.assertEqual(len(result["components"]), 6)
        self.assertEqual(result["verification"]["semantics"], "requirements-only")

    def test_unknown_claim_field_is_rejected_at_each_level(self):
        targets = [(), ("runtime",), ("documentation",), ("components", 0),
                   ("verification",), ("verification", "compileSpecimen"), ("boundaries",)]
        for target in targets:
            with self.subTest(target=target):
                self.data = copy.deepcopy(BASE)
                node = self.data
                for key in target:
                    node = node[key]
                node["nativeVerified"] = True
                self.reject("unknown keys")

    def test_missing_root_key(self):
        del self.data["boundaries"]
        self.reject("missing or unknown keys")

    def test_duplicate_json_keys(self):
        path = self.root / REGISTRY.DEFAULT_MANIFEST
        path.write_text('{"kind": "a", "kind": "b"}', encoding="utf-8")
        with self.assertRaisesRegex(REGISTRY.IndexError, "duplicate key"):
            REGISTRY.validate(self.root)

    def test_schema_version_is_integer_not_boolean(self):
        self.data["schemaVersion"] = True
        self.reject("schemaVersion")

    def test_unknown_kind(self):
        self.data["kind"] = "sealed-kit"
        self.reject("unknown kind")

    def test_wrong_module(self):
        self.data["module"] = "CalorieCam"
        self.reject("unsupported runtime module")

    def test_missing_library_product(self):
        self.alter_source("Package.swift", 'name: "DesignOSApple"', 'name: "OtherLibrary"')
        self.reject("library product missing")

    def test_id_must_match_directory(self):
        self.data["id"] = "another-style"
        self.reject("containing directory")

    def test_missing_runtime_source(self):
        (self.root / self.data["runtime"]["source"]).unlink()
        self.reject("missing file")

    def test_invalid_path_shapes(self):
        for value in ("/tmp/foreign.swift", "../outside.swift", "Sources/../bad.swift",
                      "Sources//bad.swift", "Sources/./bad.swift", "Sources\\bad.swift",
                      "https://example.com/file.swift"):
            with self.subTest(path=value):
                self.data = copy.deepcopy(BASE)
                self.data["runtime"]["source"] = value
                self.reject("path|source area")

    def test_symlink_escape(self):
        outside = Path(self.temporary.name) / "outside.swift"
        source = self.root / self.data["runtime"]["source"]
        shutil.copyfile(source, outside)
        source.unlink()
        source.symlink_to(outside)
        self.reject("path escapes repository")

    def test_wrong_source_area(self):
        self.data["components"][0]["source"] = "Examples/CalorieCam/MediaRow.swift"
        self.reject("outside expected source area")

    def test_missing_public_runtime_declaration(self):
        self.alter_source(self.data["runtime"]["source"], "public struct DesignOSAppStyle",
                          "internal struct DesignOSAppStyle")
        self.reject("public Swift declaration not found")

    def test_runtime_entry_points(self):
        for key in ("preset", "modifier", "environmentKey"):
            with self.subTest(key=key):
                self.data = copy.deepcopy(BASE)
                self.data["runtime"][key] = "invented"
                self.reject("wrong symbol")

    def test_removed_runtime_preset(self):
        self.alter_source(self.data["runtime"]["source"], "public static let editorial",
                          "public static let removed")
        self.reject("preset declaration not found")

    def test_missing_usage_documentation(self):
        (self.root / self.data["documentation"]["usage"]).unlink()
        self.reject("missing file")

    def test_missing_adoption_snippet(self):
        self.alter_source(self.data["documentation"]["usage"], ".designOSAppStyle(.editorial)",
                          ".unrelatedStyle()")
        self.reject("adoption entry point missing")

    def test_missing_component_guidance(self):
        self.alter_source(self.data["documentation"]["usage"], "DesignOSMediaRow", "UnrelatedRow")
        self.reject("component usage or organization guidance missing")

    def test_duplicate_component_id(self):
        self.data["components"][1]["id"] = self.data["components"][0]["id"]
        self.reject("duplicate id or symbol")

    def test_duplicate_component_symbol(self):
        self.data["components"][1]["symbol"] = self.data["components"][0]["symbol"]
        self.reject("duplicate id or symbol")

    def test_missing_component_from_inventory(self):
        self.data["components"].pop()
        self.reject("incomplete or extra app-style inventory")

    def test_new_app_style_component_requires_index_entry(self):
        path = self.root / "Sources/DesignOSApple/Components/DesignOSUnindexed.swift"
        path.write_text("public struct DesignOSUnindexed {\n"
                        "  @Environment(\\.designOSAppStyle) private var style\n}\n", encoding="utf-8")
        self.reject("incomplete or extra app-style inventory")

    def test_inventory_scan_cannot_escape_through_symlink(self):
        outside = Path(self.temporary.name) / "outside-component.swift"
        outside.write_text("public struct Foreign {}\n", encoding="utf-8")
        (self.root / "Sources/DesignOSApple/Components/Foreign.swift").symlink_to(outside)
        self.reject("path escapes repository")

    def test_new_shared_implementation_delegate_requires_index_entry(self):
        path = self.root / "Sources/DesignOSApple/Components/DesignOSUnindexedAction.swift"
        path.write_text("public struct DesignOSUnindexedAction: ButtonStyle {\n"
                        "  func makeBody(configuration: Configuration) -> some View {\n"
                        "    DesignOSActionButtonContent(configuration: configuration, prominence: .secondary)\n"
                        "  }\n}\n", encoding="utf-8")
        self.reject("incomplete or extra app-style inventory")

    def test_registered_delegate_must_reference_real_style_implementation(self):
        self.alter_source("Sources/DesignOSApple/Components/DesignOSSecondaryButtonStyle.swift",
                          "DesignOSActionButtonContent(", "UnrelatedButtonContent(")
        self.reject("incomplete or extra app-style inventory")

    def test_unrelated_native_component_stays_outside_style_inventory(self):
        path = self.root / "Sources/DesignOSApple/Components/UnrelatedRow.swift"
        path.write_text('public struct UnrelatedRow: View {\n  var body: some View { Text("Native") }\n}\n',
                        encoding="utf-8")
        self.assertEqual(REGISTRY.validate(self.root)["id"], "editorial")

    def test_missing_public_component_declaration(self):
        component = self.data["components"][0]
        self.alter_source(component["source"], "public struct " + component["symbol"],
                          "internal struct " + component["symbol"])
        self.reject("public Swift declaration not found")

    def test_commented_declaration_does_not_count(self):
        component = self.data["components"][0]
        path = self.root / component["source"]
        path.write_text("/*\n" + path.read_text(encoding="utf-8") + "\n*/", encoding="utf-8")
        self.reject("public Swift declaration not found")

    def test_unknown_component_kind(self):
        self.data["components"][0]["kind"] = "html-widget"
        self.reject("unknown component kind")

    def test_empty_variants(self):
        self.data["components"][0]["variants"] = []
        self.reject("nonempty array")

    def test_duplicate_states(self):
        self.data["components"][0]["requiredStates"].append("light")
        self.reject("duplicate entries")

    def test_unknown_state(self):
        self.data["components"][0]["requiredStates"].append("verified")
        self.reject("unknown value")

    def test_missing_appearance_state(self):
        self.data["components"][0]["requiredStates"].remove("dark")
        self.reject("appearance requirements missing")

    def test_missing_interaction_requirement(self):
        self.data["components"][3]["requiredStates"].remove("keyboard-focus")
        self.reject("component-kind state requirements missing")

    def test_declared_destructive_variant_requires_state(self):
        self.data["components"][3]["requiredStates"].remove("destructive")
        self.reject("destructive variant state requirement missing")

    def test_cannot_claim_verification(self):
        self.data["verification"]["semantics"] = "PASS"
        self.reject("must not claim results")

    def test_missing_compile_specimen_function(self):
        self.data["verification"]["compileSpecimen"]["symbol"] = "inventedTest"
        self.reject("test function missing")

    def test_component_must_be_composed_in_named_test(self):
        source = self.data["verification"]["compileSpecimen"]["source"]
        self.alter_source(source, "let row = DesignOSMediaRow {", "let row = AnotherRow {")
        self.reject("DesignOSMediaRow is not composed")

    def test_compile_specimen_must_apply_style(self):
        source = self.data["verification"]["compileSpecimen"]["source"]
        self.alter_source(source, ".designOSAppStyle(.editorial)", ".unrelatedStyle()")
        self.reject("style is not applied")

    def test_compile_specimen_must_be_a_source_test(self):
        self.data["verification"]["sourceTests"].pop(0)
        self.reject("compile specimen not included")

    def test_missing_native_command(self):
        (self.root / self.data["verification"]["nativeCommands"][0]).unlink()
        self.reject("missing file")

    def test_native_command_cannot_be_a_shell_expression(self):
        self.data["verification"]["nativeCommands"][0] += "; echo PASS"
        self.reject("unexpected file type")

    def test_missing_verification_tier(self):
        self.data["verification"]["requiredTiers"].remove("owner-acceptance")
        self.reject("evidence requirements missing")

    def test_boundaries_cannot_promote_authority(self):
        mutations = {
            "runtimeAuthority": "metadata", "releaseCatalogAdmission": True,
            "sealedRegistryMembership": True, "productStateOwner": "library",
        }
        for key, value in mutations.items():
            with self.subTest(key=key):
                self.data = copy.deepcopy(BASE)
                self.data["boundaries"][key] = value
                self.reject("boundaries:")


if __name__ == "__main__":
    unittest.main()
