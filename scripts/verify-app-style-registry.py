#!/usr/bin/env python3
"""Check the native discovery index without compiling Swift or claiming native quality.

The small v1 contract is defined here, not in the sealed DESIGN:OS registry. Source
checks are lexical drift guards; Swift compilation and runtime evidence remain separate.
Only reads repository files. Does not import the package or execute listed commands.
"""

import argparse
import json
import re
import sys
from pathlib import Path, PurePosixPath


DEFAULT_MANIFEST = "docs/app-styles/editorial/manifest.json"
TIERS = {
    "deterministic", "native-render", "structural-accessibility",
    "live-accessibility-and-hardware", "independent-review", "owner-acceptance",
}
STATES = {
    "light", "dark", "increased-contrast", "accessibility-dynamic-type", "long-content",
    "enabled", "pressed", "disabled", "keyboard-focus", "pointer-hover", "multiline-label",
    "photo", "no-photo", "reduce-transparency", "opaque-only-policy", "reduce-motion", "destructive",
}
KINDS = {"content-layout", "content-surface", "native-button-style", "decorative-background"}
KIND_STATES = {
    "content-layout": {"accessibility-dynamic-type", "long-content"},
    "content-surface": {"accessibility-dynamic-type", "long-content"},
    "native-button-style": {
        "accessibility-dynamic-type", "enabled", "pressed", "disabled", "keyboard-focus",
        "pointer-hover", "multiline-label",
    },
    "decorative-background": {
        "photo", "no-photo", "reduce-transparency", "opaque-only-policy", "reduce-motion",
    },
}
IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")
SLUG = re.compile(r"[a-z][a-z0-9]*(?:-[a-z0-9]+)*\Z")


class IndexError(ValueError):
    """Invalid discovery data; never a native build result."""


def require(condition, message):
    if not condition:
        raise IndexError(message)


def keys(value, expected, context):
    require(isinstance(value, dict), f"{context}: expected object")
    require(set(value) == set(expected), f"{context}: missing or unknown keys")


def string(value, context, pattern=None):
    require(isinstance(value, str) and bool(value.strip()), f"{context}: expected nonempty string")
    if pattern is not None:
        require(pattern.fullmatch(value) is not None, f"{context}: invalid identifier")
    return value


def strings(value, context, allowed=None):
    require(isinstance(value, list) and bool(value), f"{context}: expected nonempty array")
    for item in value:
        string(item, context)
    require(len(set(value)) == len(value), f"{context}: duplicate entries")
    if allowed is not None:
        require(set(value) <= allowed, f"{context}: unknown value")
    return value


def local_file(root, value, context, prefix=None, suffix=None):
    string(value, context)
    path = PurePosixPath(value)
    require(not path.is_absolute() and "\\" not in value and ":" not in value,
            f"{context}: expected repository-relative POSIX path")
    require(all(part not in ("", ".", "..") for part in value.split("/")),
            f"{context}: noncanonical or traversing path")
    if prefix is not None:
        require(value.startswith(prefix), f"{context}: outside expected source area")
    if suffix is not None:
        require(value.endswith(suffix), f"{context}: unexpected file type")
    resolved = (root / value).resolve()
    require(resolved.is_relative_to(root), f"{context}: path escapes repository")
    require(resolved.is_file(), f"{context}: missing file {value}")
    return resolved


def swift_text(path):
    # Lexical guard only. Removing comments prevents a removed declaration left in
    # a comment from satisfying discovery. This is deliberately not a Swift parser.
    return re.sub(r"/\*.*?\*/|//[^\n]*", "", path.read_text(encoding="utf-8"), flags=re.S)


def public_symbol(source, symbol, context):
    string(symbol, context, IDENTIFIER)
    require(re.search(r"\bpublic\s+(?:struct|enum|class|protocol)\s+" + re.escape(symbol)
                      + r"\b", source) is not None,
            f"{context}: public Swift declaration not found")


def app_style_inventory(root):
    """Find direct consumers and source-backed delegates to their top-level types.

    This lexical graph handles a public ButtonStyle delegating to shared internal
    button content. It does not infer runtime behavior or follow external modules.
    """
    sources, declarations, public, references = {}, {}, {}, {}
    for path in (root / "Sources/DesignOSApple/Components").glob("*.swift"):
        path = local_file(root, path.relative_to(root).as_posix(), "component inventory",
                          "Sources/DesignOSApple/Components/", ".swift")
        source = swift_text(path)
        sources[path] = source
        declared = re.findall(r"^(?:(public|internal|private|fileprivate)\s+)?"
                              r"(?:struct|enum|class|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)",
                              source, flags=re.M)
        declarations[path] = {name for _, name in declared}
        public[path] = {name for access, name in declared if access == "public"}
        references[path] = set(re.findall(r"\b([A-Z][A-Za-z0-9_]*)\s*(?:\(|<|\.)", source))
    linked = {path for path, source in sources.items()
              if re.search(r"@Environment\s*\(\s*\\\.designOSAppStyle\s*\)", source)}
    while True:
        linked_symbols = set().union(*(declarations[path] for path in linked))
        expanded = linked | {path for path in sources if references[path] & linked_symbols}
        if expanded == linked:
            return set().union(*(public[path] for path in linked))
        linked = expanded


def load_json(path):
    def no_duplicates(pairs):
        result = {}
        for key, value in pairs:
            require(key not in result, f"JSON: duplicate key {key}")
            result[key] = value
        return result
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=no_duplicates)


def validate(root, manifest=DEFAULT_MANIFEST):
    root = Path(root).resolve()
    manifest_path = local_file(root, manifest, "manifest", "docs/app-styles/", ".json")
    data = load_json(manifest_path)
    keys(data, {
        "kind", "schemaVersion", "id", "module", "runtime", "documentation", "components",
        "verification", "boundaries",
    }, "manifest")
    require(data["kind"] == "design-os-apple.app-style-index", "manifest: unknown kind")
    require(type(data["schemaVersion"]) is int and data["schemaVersion"] == 1,
            "manifest: unsupported schemaVersion")
    string(data["id"], "id", SLUG)
    require(manifest_path.parent.name == data["id"], "id: must match containing directory")
    require(data["module"] == "DesignOSApple", "module: unsupported runtime module")
    package = local_file(root, "Package.swift", "package").read_text(encoding="utf-8")
    require(re.search(r'\.library\s*\(\s*name:\s*"DesignOSApple"', package) is not None,
            "module: package library product missing")

    runtime = data["runtime"]
    keys(runtime, {"source", "symbol", "preset", "modifier", "environmentKey"}, "runtime")
    runtime_path = local_file(root, runtime["source"], "runtime.source",
                              "Sources/DesignOSApple/AppStyle/", ".swift")
    source = swift_text(runtime_path)
    public_symbol(source, runtime["symbol"], "runtime.symbol")
    require(runtime["symbol"] == "DesignOSAppStyle", "runtime: unexpected style type")
    require(runtime["preset"] == f'DesignOSAppStyle.{data["id"]}', "runtime.preset: wrong symbol")
    require(re.search(r"\bpublic\s+static\s+let\s+" + re.escape(data["id"]) + r"\b", source),
            "runtime.preset: public preset declaration not found")
    require(runtime["modifier"] == "View.designOSAppStyle(_:)", "runtime.modifier: wrong symbol")
    require(re.search(r"extension\s+View\s*\{\s*public\s+func\s+designOSAppStyle\s*"
                      r"\(\s*_\s+style:\s*DesignOSAppStyle\s*\)", source),
            "runtime.modifier: public Swift declaration not found")
    require(runtime["environmentKey"] == "EnvironmentValues.designOSAppStyle",
            "runtime.environmentKey: wrong symbol")
    require(re.search(r"extension\s+EnvironmentValues\s*\{\s*public\s+var\s+designOSAppStyle"
                      r"\s*:\s*DesignOSAppStyle\b", source),
            "runtime.environmentKey: public Swift declaration not found")

    documentation = data["documentation"]
    keys(documentation, {"usage", "organization", "reference"}, "documentation")
    docs = {key: local_file(root, value, f"documentation.{key}", "docs/", ".md")
            .read_text(encoding="utf-8") for key, value in documentation.items()}
    require(runtime["symbol"] in docs["usage"] and ".designOSAppStyle(." + data["id"] + ")"
            in docs["usage"], "documentation.usage: adoption entry point missing")

    components = data["components"]
    require(isinstance(components, list) and bool(components), "components: expected nonempty array")
    ids, symbols, source_paths = set(), set(), set()
    for component in components:
        keys(component, {"id", "symbol", "source", "kind", "variants", "requiredStates"}, "component")
        component_id = string(component["id"], "component.id", SLUG)
        symbol = string(component["symbol"], "component.symbol", IDENTIFIER)
        require(component_id not in ids and symbol not in symbols, "component: duplicate id or symbol")
        ids.add(component_id)
        symbols.add(symbol)
        path = local_file(root, component["source"], f"{component_id}.source",
                          "Sources/DesignOSApple/Components/", ".swift")
        require(path not in source_paths, "component: duplicate source")
        source_paths.add(path)
        public_symbol(swift_text(path), symbol, f"{component_id}.symbol")
        require(symbol in docs["usage"] and symbol in docs["organization"],
                f"{component_id}: component usage or organization guidance missing")
        string(component["kind"], f"{component_id}.kind")
        require(component["kind"] in KINDS, f"{component_id}.kind: unknown component kind")
        for variant in strings(component["variants"], f"{component_id}.variants"):
            string(variant, f"{component_id}.variant", SLUG)
        states = strings(component["requiredStates"], f"{component_id}.requiredStates", STATES)
        require({"light", "dark", "increased-contrast"} <= set(states),
                f"{component_id}: appearance requirements missing")
        require(KIND_STATES[component["kind"]] <= set(states),
                f"{component_id}: component-kind state requirements missing")
        if "destructive" in component["variants"]:
            require("destructive" in states, f"{component_id}: destructive variant state requirement missing")

    # Keep the full app-style inventory addressable without a hardcoded component
    # count or edits to the frozen release catalog. Existing non-app-style rows
    # are outside this projection. This is a lexical coverage check, not reflection.
    discovered = app_style_inventory(root)
    require(symbols == discovered, "components: incomplete or extra app-style inventory")

    verification = data["verification"]
    keys(verification, {"semantics", "compileSpecimen", "sourceTests", "nativeCommands", "requiredTiers"},
         "verification")
    require(verification["semantics"] == "requirements-only", "verification: must not claim results")
    specimen = verification["compileSpecimen"]
    keys(specimen, {"source", "symbol"}, "compileSpecimen")
    specimen_path = local_file(root, specimen["source"], "compileSpecimen.source",
                               "Tests/DesignOSAppleTests/", ".swift")
    specimen_source = swift_text(specimen_path)
    string(specimen["symbol"], "compileSpecimen.symbol", IDENTIFIER)
    match = re.search(r"\bfunc\s+" + re.escape(specimen["symbol"]) + r"\s*\(\s*\)\s*\{",
                      specimen_source)
    require(match is not None, "compileSpecimen: test function missing")
    body_start, depth, position = match.end(), 1, match.end()
    while depth and position < len(specimen_source):
        depth += (specimen_source[position] == "{") - (specimen_source[position] == "}")
        position += 1
    require(depth == 0, "compileSpecimen: unbalanced body")
    specimen_body = specimen_source[body_start:position - 1]
    for symbol in symbols:
        require(re.search(r"\b" + re.escape(symbol) + r"\s*[(<{]", specimen_body),
                f"compileSpecimen: {symbol} is not composed by the named test")
    require(".designOSAppStyle(." + data["id"] + ")" in specimen_body,
            "compileSpecimen: style is not applied")
    source_tests = strings(verification["sourceTests"], "sourceTests")
    require(specimen["source"] in source_tests, "sourceTests: compile specimen not included")
    for path in source_tests:
        text = swift_text(local_file(root, path, "sourceTests", "Tests/DesignOSAppleTests/", ".swift"))
        require("@Test" in text, "sourceTests: no Swift Testing declarations")
    for path in strings(verification["nativeCommands"], "nativeCommands"):
        local_file(root, path, "nativeCommands", "scripts/", ".sh")
    require(set(strings(verification["requiredTiers"], "requiredTiers", TIERS)) == TIERS,
            "requiredTiers: evidence requirements missing")

    boundaries = data["boundaries"]
    keys(boundaries, {"runtimeAuthority", "releaseCatalogAdmission", "sealedRegistryMembership",
                      "productStateOwner"}, "boundaries")
    require(boundaries["runtimeAuthority"] == "swift-source", "boundaries: wrong runtime authority")
    require(boundaries["releaseCatalogAdmission"] is False, "boundaries: cannot admit release stories")
    require(boundaries["sealedRegistryMembership"] is False, "boundaries: cannot claim sealed registration")
    require(boundaries["productStateOwner"] == "consumer", "boundaries: product state must stay consumer-owned")
    return data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--manifest", default=DEFAULT_MANIFEST, help="Repository-relative index path")
    args = parser.parse_args()
    try:
        data = validate(args.root, args.manifest)
    except (IndexError, OSError, ValueError, TypeError) as error:
        print(f"E_APP_STYLE_INDEX: {error}", file=sys.stderr)
        return 1
    print(f'App-style index: {data["id"]}, {len(data["components"])} source-backed components; structural check passed.')
    print("Requirements only. Native compilation, rendering, accessibility, review, and acceptance are separate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
