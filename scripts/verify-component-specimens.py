#!/usr/bin/env python3
"""Check fixture/manifest/test binding consistency. Not Swift or visual certification."""
import hashlib
import json
from pathlib import Path
import re

root = Path(__file__).resolve().parent.parent
manifest = json.loads((root / 'docs/component-native-specimen-manifest.json').read_text())
source = (root / manifest['fixture_source']).read_text()
tests = (root / manifest['capture_test_source']).read_text()
records = manifest['records']
ids = [record['id'] for record in records]
routes = re.findall(r'\.init\(id: "([^"]+)"', source)
cases = re.findall(r'case "([^"]+)":', source)
assert len(ids) == len(set(ids)), 'Duplicate component IDs'
assert len(routes) == len(set(routes)), 'Duplicate launch routes'
assert set(ids) == set(routes) == set(cases), 'Manifest/route/fixture case mismatch'
for record in records:
    assert '"' + record['id'] + '"' in tests, record['id'] + ' has no capture call'
    path = root / record['source']
    assert path.is_file(), 'Missing source: ' + record['source']
    assert hashlib.sha256(path.read_bytes()).hexdigest() == record['source_sha256'], 'Stale fixture source binding: ' + record['id']
    if record['rendering_kind'] == 'actual_public_runtime_component':
        assert re.search(r'\b' + re.escape(record['symbol']) + r'\s*(?:\(|\{)', source), 'Missing actual API invocation: ' + record['id']
    keys = [(case['state'], case['appearance']) for case in record['capture_cases']]
    assert len(keys) == len(set(keys)), 'Duplicate capture case: ' + record['id']
    assert ('default', 'light') in keys and ('default', 'dark') in keys
    assert record['native_status'] == 'not_run' and record['visual_status'] == 'not_reviewed', 'Planned fixture manifest must not masquerade as executed evidence'
count = sum(len(record['capture_cases']) for record in records)
assert count == manifest['planned_capture_count_per_target']
assert 'colorSchemeContrast' not in source, 'Contrast requires the actual platform setting, not a read-only environment setter'
assert 'state: "increased-contrast"' not in tests, 'Unsupported contrast capture must not be claimed'
assert all(case['state'] != 'increased-contrast' for record in records for case in record['capture_cases'])
assert hashlib.sha256(source.encode()).hexdigest() == manifest['fixture_source_sha256'], 'Stale fixture source hash'
assert hashlib.sha256(tests.encode()).hexdigest() == manifest['capture_test_source_sha256'], 'Stale capture test hash'
assert '.focused(' not in source, 'Fixtures must not force native focus'
assert 'component-ready-' in source and 'component-ready-' in tests
print(f'PASS: {len(ids)} source fixtures, {count} planned captures per target. Native compilation/execution and visual review remain separate.')
