#!/usr/bin/env python3
"""Portable source/provenance gate. This is not a Swift compiler or visual certification.

Index schema v2 deliberately keeps atlas research, source presence, native execution and
visual review independent. Receipts bind to a digest of the complete runtime module;
a source edit invalidates previous pass receipts. --root supports isolated red controls.
"""
import argparse
import hashlib
import json
import re
from collections import Counter
from pathlib import Path

LAYERS = ['primitive', 'semantic', 'composite', 'shell', 'screen']
ROOTS = {
    'primitive': 'Sources/DesignOSApple/Primitives/Editorial',
    'semantic': 'Sources/DesignOSApple/Components/Semantic',
    'composite': 'Sources/DesignOSApple/Components/Composite',
    'shell': 'Sources/DesignOSApple/Shells',
    'screen': 'Sources/DesignOSApple/Screens',
}
FROZEN = ['design/design.tokens.json', 'design/component-registry.json', 'design/ds.manifest.json']
PINNED_FROZEN_SHA256 = {'design/design.tokens.json': '8eb0c9075b7d08d9835958cf18160e18aeafd8257e00f5e3676955da5ed27e33', 'design/component-registry.json': '492b7a539ff6b7148b45608b221549d9732c5b658e0d404c286163e38aa1bd92', 'design/ds.manifest.json': '5dbcd8f9ce5ae2d6c09a7c6b8966a89cfcc4d8f41f76b85699d1672fda718cbb'}
PINNED_INVENTORY_SHA256 = 'c29810ee45d6f652d1283209ad5d0c742ab259091a832ca9f410e88c11d224c9'
HEX = re.compile(r'^[0-9a-f]{64}$')
ID = re.compile(r'^(primitive|semantic|composite|shell|screen)/[a-z][a-z0-9-]*$')
DECL = re.compile(r'\b(?:public|open)\s+(?:(?:final|static|class|nonisolated|mutating|override|indirect|required|convenience)\s+)*(struct|enum|class|actor|protocol|typealias|func|var|let|init|subscript)\b\s*([A-Za-z_][A-Za-z_0-9]*)?')

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def code(text):
    # Discard comments and literal contents so documentation cannot invent bindings.
    return re.sub(r'/\*.*?\*/|//[^\n]*|""".*?"""|"(?:\\.|[^"\\])*"', ' ', text, flags=re.S)

def declarations(text):
    return sorted(set(k if k in ('init', 'subscript') else f'{k} {n}' for k, n in DECL.findall(code(text))))

def module_digest(root):
    files = sorted((root / 'Sources/DesignOSApple').rglob('*.swift'))
    payload = ''.join(f'{p.relative_to(root).as_posix()}\0{sha(p)}\n' for p in files)
    return hashlib.sha256(payload.encode()).hexdigest()

class Invalid(ValueError):
    pass

def require(ok, message):
    if not ok:
        raise Invalid(message)

def safe(root, value):
    require(isinstance(value, str) and value and not Path(value).is_absolute(), 'unsafe path')
    require('..' not in Path(value).parts and '\\' not in value, f'unsafe path: {value}')
    path = root / value
    require(path.resolve().is_relative_to(root.resolve()), f'unsafe path: {value}')
    require(path.is_file(), f'missing artifact: {value}')
    return path

def unique(items, key, context):
    require(isinstance(items, list), f'{context} must be an array')
    result = {}
    for item in items:
        require(isinstance(item, dict) and isinstance(item.get(key), str), f'{context}: invalid object/ID')
        require(item[key] not in result, f'{context}: duplicate {item[key]}')
        result[item[key]] = item
    return result

def receipt(root, evidence, tier, digest, state_id=None):
    require(isinstance(evidence, dict), f'{tier}: receipt required')
    require(evidence.get('result') == 'passed', f'{tier}: result must be passed')
    require(evidence.get('module_sha256') == digest, f'{tier}: stale module source digest')
    require(re.fullmatch(r'[0-9a-f]{40}', evidence.get('source_revision', '')) is not None, f'{tier}: source revision required')
    require(evidence.get('platform') in ('iOS', 'iPadOS', 'macOS'), f'{tier}: unsupported platform')
    for field in ('command', 'toolchain'):
        require(isinstance(evidence.get(field), str) and len(evidence[field].strip()) > 3 and evidence[field].lower() not in ('todo', 'unknown', 'placeholder'), f'{tier}: {field} required')
    artifact = safe(root, evidence.get('artifact'))
    require(HEX.fullmatch(evidence.get('artifact_sha256', '')) and sha(artifact) == evidence['artifact_sha256'], f'{tier}: artifact hash mismatch')
    require(artifact.stat().st_size > 0, f'{tier}: empty artifact')
    if state_id:
        require(evidence.get('source_screen_id') == state_id, f'{tier}: wrong screen-state receipt')
    if tier == 'visual_reviewed':
        for field in ('reviewer', 'appearance', 'window', 'variant_id'):
            require(isinstance(evidence.get(field), str) and evidence[field].strip(), f'visual_reviewed: {field} required')
        capture = safe(root, evidence.get('capture'))
        require(sha(capture) == evidence.get('capture_sha256'), 'visual_reviewed: capture hash mismatch')

# These four atlas contracts intentionally reuse native/existing content instead of
# manufacturing public wrapper types. Recipe bindings are consumer references, not
# runtime dependency edges (a confirmation recipe may consume a screen).
RECIPE_CONTRACTS = {
    'composite/form-section': ('native_delegation', [('SwiftUI', 'Form'), ('SwiftUI', 'Section')]),
    'composite/sectioned-media-collection': ('native_delegation', [('SwiftUI', 'Section'), ('SwiftUI', 'ForEach'), ('DesignOSApple', 'shell/flat-list'), ('DesignOSApple', 'semantic/media-row')]),
    'composite/status-content': ('existing_composition', [('DesignOSApple', 'semantic/status-message'), ('SwiftUI', 'Button')]),
    'composite/confirmation-content': ('existing_composition', [('SwiftUI', 'Text'), ('SwiftUI', 'Button'), ('DesignOSApple', 'screen/confirmation')]),
}

def function_body(text, name):
    """Locate a named compile-fixture function; comments/literals cannot satisfy calls."""
    cleaned = code(text)
    match = re.search(r'\bfunc\s+' + re.escape(name) + r'\s*\([^)]*\)[^{]*\{', cleaned)
    require(match is not None, f'recipe fixture function missing: {name}')
    start = match.end()
    depth = 1
    for offset in range(start, len(cleaned)):
        depth += (cleaned[offset] == '{') - (cleaned[offset] == '}')
        if depth == 0:
            return cleaned[start:offset]
    raise Invalid(f'unclosed recipe fixture function: {name}')

def validate_recipe(root, rid, item, records):
    require(rid in RECIPE_CONTRACTS, f'{rid}: unknown recipe contract')
    require(item.get('source') is None and item.get('symbol') is None and item.get('visibility') is None
            and not item.get('public_declarations') and not item.get('source_sha256'),
            f'{rid}: recipe is not a source API binding')
    require(item.get('ownership') == 'host-app', f'{rid}: recipe consumer boundary required')
    kind, required_bindings = RECIPE_CONTRACTS[rid]
    recipe = item.get('recipe')
    require(isinstance(recipe, dict) and recipe.get('kind') == kind, f'{rid}: invalid recipe disposition')
    bindings = recipe.get('bindings')
    require(isinstance(bindings, list) and bindings == [dict(module=m, reference=r) for m, r in required_bindings],
            f'{rid}: recipe native/existing bindings mismatch')
    fixture = safe(root, item.get('compile_fixture'))
    require(fixture.suffix == '.swift' and fixture.is_relative_to(root / 'Tests/DesignOSAppleTests'), f'{rid}: recipe fixture must be package test source')
    require(sha(fixture) == item.get('compile_fixture_sha256'), f'{rid}: stale recipe fixture source')
    name = recipe.get('fixture_function')
    require(isinstance(name, str) and re.fullmatch(r'[A-Za-z_]\w*', name), f'{rid}: recipe fixture function required')
    source = fixture.read_text()
    body = function_body(source, name)
    require(re.search(r'\bimport\s+SwiftUI\b', code(source)), f'{rid}: recipe must import native SwiftUI')
    doc = safe(root, item.get('documentation'))
    require(rid in doc.read_text() and name in doc.read_text(), f'{rid}: recipe documentation must name contract and fixture')
    for module, reference in required_bindings:
        if module == 'DesignOSApple':
            require(reference in records and records[reference]['source_status'] == 'source_present', f'{rid}: recipe references unavailable API')
            symbol = records[reference].get('symbol')
            require(isinstance(symbol, str) and symbol, f'{rid}: recipe API symbol missing')
            require(re.search(r'\bimport\s+DesignOSApple\b', code(source)), f'{rid}: recipe must import package')
        else:
            symbol = reference
        require(re.search(r'\b' + re.escape(symbol) + r'\s*(?:\(|\{)', body), f'{rid}: recipe fixture does not call {symbol}')

def validate_tiers(root, rid, item, digest):
    require(item.get('native_status') in ('not_run', 'passed'), f'{rid}: invalid native status')
    require(item.get('visual_status') in ('not_run', 'reviewed'), f'{rid}: invalid visual status')
    evidence = item.get('evidence', {})
    require(isinstance(evidence, dict), f'{rid}: evidence must be an object')
    if item['native_status'] == 'passed':
        native = evidence.get('native_tested')
        require(isinstance(native, dict), 'native_tested: receipt required')
        if item.get('compile_fixture'):
            require(native.get('compile_fixture') == item['compile_fixture'], f'{rid}: native receipt fixture mismatch')
            require(native.get('compile_fixture_sha256') == sha(safe(root, item['compile_fixture'])), f'{rid}: stale native compile fixture')
        receipt(root, native, 'native_tested', digest)
    else:
        require(not evidence.get('native_tested'), f'{rid}: contradictory native receipt')
    if item['visual_status'] == 'reviewed':
        require(item['native_status'] == 'passed', f'{rid}: visual pass without native test')
        visual = evidence.get('visual_reviewed')
        require(isinstance(visual, dict), 'visual_reviewed: receipt required')
        if item.get('compile_fixture'):
            require(visual.get('compile_fixture') == item['compile_fixture'], f'{rid}: visual receipt fixture mismatch')
            require(visual.get('compile_fixture_sha256') == sha(safe(root, item['compile_fixture'])), f'{rid}: stale visual compile fixture')
        receipt(root, visual, 'visual_reviewed', digest)
    else:
        require(not evidence.get('visual_reviewed'), f'{rid}: contradictory visual receipt')

def verify(root):
    index = json.loads((root / 'docs/layered-kit-index.json').read_text())
    coverage = json.loads((root / 'docs/luma-kit-coverage.json').read_text())
    inventory_path = root / 'docs/luma-layout-atlas.inventory.json'
    inventory = json.loads(inventory_path.read_text())
    require(index.get('schema_version') == 2 and coverage.get('schema_version') == 1, 'unsupported schema version')
    require(index.get('module') == 'DesignOSApple', 'wrong module ownership')
    require(index.get('discovery_roots') == ROOTS, 'discovery roots must be exhaustive and pinned')
    require(index.get('frozen_sha256') == PINNED_FROZEN_SHA256, 'frozen authority pins changed')
    for path, expected in index['frozen_sha256'].items():
        require(sha(safe(root, path)) == expected, f'frozen authority changed: {path}')
    require(coverage['source']['inventory_sha256'] == sha(inventory_path) == PINNED_INVENTORY_SHA256, 'stale inventory source hash')
    require(coverage['source']['version_id'] == inventory['version_id'], 'wrong inventory version')
    records = unique(index.get('records'), 'id', 'layered registry')
    proposed = unique(coverage['architecture']['registry'], 'id', 'research registry')
    require(set(proposed) <= set(records), 'unregistered proposed dependency')
    digest = module_digest(root)
    bindings = {}
    type_owners = {}
    for rid, item in records.items():
        require(ID.fullmatch(rid) and item.get('layer') == rid.split('/')[0], f'invalid typed ID: {rid}')
        require(item.get('module') == 'DesignOSApple', f'{rid}: wrong module ownership')
        require(item.get('ownership') in ('kit', 'platform', 'provider', 'host-app'), f'{rid}: boundary required')
        if rid in ('shell/native-host', 'screen/native-presentation'):
            require(item['ownership'] == 'platform', f'{rid}: platform boundary misrepresented')
        if rid == 'screen/provider-host':
            require(item['ownership'] == 'provider', f'{rid}: provider boundary misrepresented')
        require(isinstance(item.get('boundary'), str) and item['boundary'].strip(), f'{rid}: explicit boundary required')
        require(item.get('source_status') in ('planned', 'source_present', 'recipe_present'), f'{rid}: invalid source status')
        if rid in RECIPE_CONTRACTS:
            require(item['source_status'] in ('planned', 'recipe_present'), f'{rid}: recipe cannot be counted as a source API')
        elif item['source_status'] != 'recipe_present':
            require(not item.get('recipe'), f'{rid}: source API cannot carry recipe claims')
        deps = item.get('dependencies')
        require(isinstance(deps, list) and len(set(deps)) == len(deps), f'{rid}: invalid dependencies')
        for dep in deps:
            require(dep in records, f'{rid}: unknown reference {dep}')
            require(LAYERS.index(records[dep]['layer']) <= LAYERS.index(item['layer']), f'{rid}: upward dependency {dep}')
        if item['source_status'] == 'planned':
            require(item.get('source') is None and item.get('symbol') is None, f'{rid}: planned API has fabricated source binding')
            require(item.get('native_status') == 'not_run' and item.get('visual_status') == 'not_run', f'{rid}: planned API cannot claim passes')
            require(not item.get('evidence'), f'{rid}: planned API cannot claim evidence')
            continue
        if item['source_status'] == 'recipe_present':
            validate_recipe(root, rid, item, records)
            validate_tiers(root, rid, item, digest)
            continue
        source = safe(root, item.get('source'))
        require(source.suffix == '.swift' and source.is_relative_to(root / 'Sources/DesignOSApple'), f'{rid}: invalid source module')
        require(sha(source) == item.get('source_sha256'), f'{rid}: stale source hash')
        text = source.read_text()
        symbol = item.get('symbol')
        require(isinstance(symbol, str) and re.search(r'\b(?:struct|enum|class|actor|protocol|typealias)\s+' + re.escape(symbol) + r'\b', code(text)), f'{rid}: missing actual API declaration')
        require(item.get('visibility') in ('public', 'internal', 'package'), f'{rid}: invalid visibility')
        is_public = any(d.split(' ')[-1] == symbol for d in declarations(text))
        require((item['visibility'] == 'public') == is_public, f'{rid}: incorrect API visibility')
        require(item.get('public_declarations') == declarations(text), f'{rid}: unregistered public symbol')
        require(item['source'] not in bindings, f'{rid}: duplicate source binding')
        bindings[item['source']] = rid
        require(symbol not in type_owners, f'{rid}: duplicate source symbol {symbol}')
        type_owners[symbol] = rid
        if is_public and source.is_relative_to(root / ROOTS[item['layer']]):
            require(re.search(r'\bpublic\s+struct\s+' + re.escape(symbol) + r'\b', code(text)) and re.search(r'\bpublic\s+var\s+body\s*:\s*some\s+View\s*\{', code(text)), f'{rid}: marker-only API is not a concrete view')
            require(not re.search(r'\bbody\s*:\s*some\s+View\s*\{\s*(?:return\s+)?EmptyView\s*\(\s*\)\s*\}', code(text)), f'{rid}: placeholder EmptyView body')
            doc = safe(root, item.get('documentation'))
            fixture = safe(root, item.get('compile_fixture'))
            require(symbol in doc.read_text(), f'{rid}: documentation does not name API')
            require(fixture.suffix == '.swift' and re.search(r'\b' + symbol + r'\s*(?:\(|\{)', code(fixture.read_text())), f'{rid}: compile fixture does not exercise API')
        validate_tiers(root, rid, item, digest)
    # Recursion is intentional: neither new nested folders nor public helper declarations escape.
    for layer, directory in ROOTS.items():
        for path in (root / directory).rglob('*.swift'):
            relative = path.relative_to(root).as_posix()
            require(relative in bindings, f'orphan Swift file: {relative}')
            require(records[bindings[relative]]['layer'] == layer, f'wrong directory layer: {relative}')
    # Check actual source references as well as the declared graph. This is lexical, not type checking.
    for path, rid in bindings.items():
        tokens = set(re.findall(r'\b[A-Za-z_]\w*\b', code((root / path).read_text())))
        for symbol, owner in type_owners.items():
            if owner != rid and symbol in tokens:
                require(LAYERS.index(records[owner]['layer']) <= LAYERS.index(records[rid]['layer']), f'{rid}: source reaches upward to {owner}')
                require(owner in records[rid]['dependencies'], f'{rid}: undeclared source dependency {owner}')
        require(not re.search(r'\bimport\s+(?:CalorieCam\w*|DesignOSAppleCatalog)\b', code((root / path).read_text())), f'{rid}: consuming-app import')
    active, done = set(), set()
    def visit(rid):
        require(rid not in active, f'dependency cycle: {rid}')
        if rid in done:
            return
        active.add(rid)
        for dep in records[rid]['dependencies']:
            visit(dep)
        active.remove(rid)
        done.add(rid)
    for rid in records:
        visit(rid)
    original = unique(inventory['screens'], 'id', 'inventory')
    screens = unique(coverage['screens'], 'source_screen_id', 'screen mappings')
    require(len(original) == 393 and set(screens) == set(original), 'missing or unknown source IDs: expected exact 393')
    counts = Counter()
    family_defaults = {}
    overrides = 0
    for sid, screen in screens.items():
        src = original[sid]
        require(screen.get('source_asset_sha256') == src['asset_sha256'], f'{sid}: invalid source hash')
        require(screen.get('source_index') == src['index'] and screen.get('source_url') == src['mobbin_url'], f'{sid}: altered source identity')
        obs = screen['observed']
        require((obs.get('family'), obs.get('state'), obs.get('anatomy')) == (src['family'], src['state'], src['observations']), f'{sid}: altered observed anatomy/state')
        expected_variant = re.sub(r'[^a-z0-9]+', '-', src['state'].lower()).strip('-')
        require(obs.get('variant_id') == expected_variant and expected_variant, f'{sid}: missing/invalid state variant')
        mapping = screen['proposed_reconstruction']
        for key, layer in [('screen_type_id', 'screen'), ('shell_id', 'shell')]:
            require(mapping.get(key) in records and records[mapping[key]]['layer'] == layer, f'{sid}: unknown or mistyped reference {key}')
        for key, layer in [('composite_ids', 'composite'), ('semantic_ids', 'semantic')]:
            require(isinstance(mapping.get(key), list) and len(set(mapping[key])) == len(mapping[key]), f'{sid}: invalid {key}')
            require(all(r in records and records[r]['layer'] == layer for r in mapping[key]), f'{sid}: unknown or mistyped reference {key}')
        require(isinstance(mapping.get('basis'), str) and mapping['basis'].strip() and isinstance(mapping.get('rule_id'), str), f'{sid}: unexplained family mapping')
        rule = mapping['rule_id']
        if rule.startswith('observed-family/'):
            require(rule == 'observed-family/' + re.sub(r'[^a-z0-9]+', '-', src['family'].lower()).strip('-'), f'{sid}: wrong observed-family rule')
            assignment = (mapping['screen_type_id'], mapping['shell_id'])
            require(src['family'] not in family_defaults or family_defaults[src['family']] == assignment, f'{sid}: family override needs an explicit anatomy rule')
            family_defaults[src['family']] = assignment
        else:
            require(rule == f"anatomy-override/{src['index']:03d}", f'{sid}: invalid anatomy override rule')
            require(len(mapping['basis'].strip()) >= 30, f'{sid}: anatomy override needs an explanation')
            overrides += 1
        require(isinstance(mapping.get('native_capabilities'), list) and all(isinstance(n, str) and n.strip() for n in mapping['native_capabilities']), f'{sid}: native boundary missing')
        require(mapping.get('mapping_status') == 'proposed_source_backed', f'{sid}: research mapping cannot claim implementation')
        state = screen['status']
        require(state.get('research_mapping') == 'mapped', f'{sid}: research status invalid')
        # v1 atlas receipts are intentionally conservative. Positive per-state claims require
        # a future explicit fixture schema, not an arbitrary path or a generic family compile.
        require(state.get('screen_state_implementation') == 'not_verified', f'{sid}: unsupported exact-state implementation claim; schema v1 has no state fixture binding')
        require(state.get('native_runtime_test') == 'not_run', f'{sid}: unsupported exact-state native pass')
        require(state.get('visual_comparison') == 'not_run', f'{sid}: unsupported exact-state visual pass')
        require(screen.get('implementation_artifacts') == [] and screen.get('test_artifacts') == [], f'{sid}: untyped exact-state evidence')
        counts[mapping['screen_type_id']] += 1
    summary = coverage['coverage']
    for key in ('source_screens', 'distinct_source_ids', 'research_mapped', 'source_hashes_rechecked'):
        require(summary.get(key) == 393, f'false coverage aggregate: {key}')
    for key in ('unmapped', 'screen_states_implementation_verified', 'screen_states_native_runtime_tested', 'screen_states_visually_compared'):
        require(summary.get(key) == 0, f'false coverage aggregate: {key}')
    require(summary.get('explicit_anatomy_overrides') == overrides, 'false anatomy override aggregate')
    require(summary.get('screen_type_counts') == dict(counts), 'false screen family totals')
    require(summary.get('shell_counts') == dict(Counter(s['proposed_reconstruction']['shell_id'] for s in screens.values())), 'false shell totals')
    return {'research_mapped': len(screens), 'source_present_records': sum(r['source_status'] == 'source_present' for r in records.values()), 'public_source_present_apis': sum(r['source_status'] == 'source_present' and r.get('visibility') == 'public' for r in records.values()), 'internal_source_present_records': sum(r['source_status'] == 'source_present' and r.get('visibility') != 'public' for r in records.values()), 'planned_contracts': sum(r['source_status'] == 'planned' for r in records.values()), 'source_present_recipes': sum(r['source_status'] == 'recipe_present' for r in records.values()), 'native_delegation_recipes': sum(r['source_status'] == 'recipe_present' and r['recipe']['kind'] == 'native_delegation' for r in records.values()), 'native_tested_apis': sum(r['source_status'] == 'source_present' and r['native_status'] == 'passed' for r in records.values()), 'native_tested_recipes': sum(r['source_status'] == 'recipe_present' and r['native_status'] == 'passed' for r in records.values()), 'visual_reviewed_apis': sum(r['source_status'] == 'source_present' and r['visual_status'] == 'reviewed' for r in records.values()), 'visual_reviewed_recipes': sum(r['source_status'] == 'recipe_present' and r['visual_status'] == 'reviewed' for r in records.values()), 'exact_screen_states_source_verified': 0, 'exact_screen_states_native_tested': 0, 'exact_screen_states_visual_reviewed': 0}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    try:
        print(json.dumps({'result': 'passed', 'scope': 'portable source/provenance only', **verify(args.root.resolve())}, indent=2))
    except (Invalid, KeyError, TypeError, ValueError, OSError) as error:
        print(f'FAIL layered kit: {error}')
        return 1
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
