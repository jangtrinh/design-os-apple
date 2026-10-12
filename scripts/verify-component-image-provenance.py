#!/usr/bin/env python3
"""Verify the exact native component-catalog image set; does not establish visual acceptance."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

DIRECTORY = 'docs/assets/components'
MANIFEST_SHA256 = '53322222c939046166e7994dfd28601c0ef8db00a84cde625f1f623a37394775'
ROUTES = {'confirmation','discovery','flat-collection','focused-task','freeform-editor','grouped-form','hero-collection','media-composer','media-detail','message-thread','native-presentation','onboarding','profile-detail','provider-host','record-detail','search-selection','status','utility-canvas'}
COMPONENT_IDS = ('primitive/corner-geometry', 'semantic/media-frame', 'semantic/avatar', 'semantic/labeled-value-row', 'semantic/status-message', 'semantic/media-row', 'semantic/section-header', 'semantic/content-surface', 'semantic/primary-action', 'semantic/secondary-action', 'semantic/media-backdrop', 'composite/field-group', 'composite/identity-header', 'composite/media-detail-header', 'composite/media-composer-header', 'composite/choice-row', 'composite/selection-summary', 'composite/category-rail', 'composite/message-bubble', 'composite/conversation-composer', 'composite/record-summary', 'composite/utility-overlay', 'shell/flat-list', 'shell/flat-scroll', 'shell/grouped-form', 'shell/ambient-scroll', 'shell/focused-task', 'shell/conversation', 'shell/utility-canvas', 'shell/adaptive-navigation', 'shell/native-host', 'semantic/text-field-modifier', 'semantic/list-row', 'semantic/sidebar-row', 'foundation/color-role', 'foundation/typography-role', 'foundation/surface-role', 'composite/sectioned-media-collection', 'composite/form-section', 'composite/confirmation-content', 'composite/status-content', 'native/button-and-toolbar-action-recipe', 'native/content-unavailable-view-recipe', 'native/elevated-background-recipe', 'native/hierarchical-style-recipe', 'native/list-sidebar-and-disclosure-recipe', 'native/material-and-glass-surface-recipe', 'native/menu-context-and-edit-actions-recipe', 'native/navigation-tabs-and-toolbars-recipe', 'native/picker-and-date-color-input-recipe', 'native/presentation-and-share-recipe', 'native/progress-slider-stepper-recipe', 'native/text-search-and-keyboard-input-recipe')
SCREEN_EXPECTED = {f'iphone-{route}-{theme}.webp': ('screen/' + route, 'screen-family', theme) for route in ROUTES for theme in ('light','dark')}
ISOLATED_EXPECTED = {f"iphone-{component_id.replace('/', '-')}-{theme}.webp": (component_id, 'isolated-component', theme) for component_id in COMPONENT_IDS for theme in ('light','dark')}
EXPECTED_RECORDS = SCREEN_EXPECTED | ISOLATED_EXPECTED
EXPECTED = set(EXPECTED_RECORDS)
# Measured reviewed set: 28,437,254 bytes; largest lossless image: 1,669,186 bytes.
MAX_ASSET_BYTES = 1_750_000
MAX_TOTAL_BYTES = 30_000_000

def require(condition, message):
    if not condition:
        raise ValueError(f'E_COMPONENT_IMAGE: {message}')

def regular(root, relative):
    path = root / relative
    require(path.is_file() and not path.is_symlink() and path.resolve() == path, f'nonregular or symlinked {relative}')
    return path

def verify(root):
    root = Path(root).resolve(strict=True)
    directory = root / DIRECTORY
    require(directory.is_dir() and not directory.is_symlink() and directory.resolve() == directory, 'missing or symlinked component image directory')
    require({p.name for p in directory.iterdir()} == EXPECTED | {'manifest.json'}, 'unexpected or missing component image file')
    raw = regular(root, f'{DIRECTORY}/manifest.json').read_bytes()
    require(hashlib.sha256(raw).hexdigest() == MANIFEST_SHA256, 'unreviewed provenance manifest')
    manifest = json.loads(raw)
    require(manifest['version'] == 2, 'unsupported version')
    require(manifest['source']['head_sha'] == '1898ce28861d642f57dccd88fd57afcbe3be5bb9' and manifest['source']['run_id'] == 38157622095, 'wrong source revision or run')
    assets = manifest['assets']
    require(len(assets) == 142 and {a['file'] for a in assets} == EXPECTED, 'wrong asset inventory')
    total = 0
    for asset in assets:
        name = asset['file']
        data = regular(root, f'{DIRECTORY}/{name}').read_bytes()
        require(len(data) == asset['byte_size'] and 0 < len(data) <= MAX_ASSET_BYTES, f'invalid byte size {name}')
        total += len(data)
        require(hashlib.sha256(data).hexdigest() == asset['sha256'], f'hash mismatch {name}')
        require(len(data) >= 25 and data[:4] == b'RIFF' and data[8:16] == b'WEBPVP8L' and data[20] == 0x2f, f'not lossless WebP {name}')
        require(struct.unpack('<I', data[4:8])[0] == len(data) - 8, f'invalid WebP container size {name}')
        bits = struct.unpack('<I', data[21:25])[0]
        dimensions = ((bits & 0x3fff) + 1, ((bits >> 14) & 0x3fff) + 1)
        require(dimensions == (asset['width'],asset['height']), f'wrong dimensions {name}')
        component_id, scope, appearance = EXPECTED_RECORDS[name]
        require((asset['component_id'], asset['scope'], asset['appearance']) == (component_id, scope, appearance), f'wrong component mapping {name}')
        require(asset['state'] == ('default_family_fixture' if scope == 'screen-family' else 'default') and asset['platform'] == 'iPhone', f'wrong platform or state {name}')
        require(asset['kind'] == 'native-ci-screenshot', f'wrong capture source {name}')
        source = asset['source']
        for field in ('sha256', 'artifact_sha256', 'manifest_sha256', 'attachment_proof_sha256', 'receipt_sha256'):
            require(isinstance(source[field], str) and len(source[field]) == 64 and all(c in '0123456789abcdef' for c in source[field]), f'invalid source hash {field}: {name}')
        require(source['test_identifier'].startswith('LayeredKitPreviewUITests/' if scope == 'screen-family' else 'ComponentInventoryUITests/'), f'wrong test source {name}')
        require(source['original_width'] == 1206 and source['original_height'] == 2622, f'wrong native dimensions {name}')
        require(source['exported_file'].startswith('screenshots-iPhone') and source['exported_file'].endswith('.png') and '..' not in source['exported_file'], f'wrong source path {name}')
        require(source['test_result'] == 'Success' and source['run_attempt'] == 1, f'wrong native execution {name}')
        if scope == 'screen-family':
            require(source['binding'] is None and source['binding_sha256'] is None and source['binding_kind'] == 'derived_original_suite_export_without_generic_component_binding', f'fabricated screen binding {name}')
        else:
            binding = source['binding']['raw']
            require(source['binding_kind'] == 'emitted_native_app_screenshot_binding' and len(source['binding_sha256']) == 64, f'missing emitted binding {name}')
            require((binding['component_id'],binding['state'],binding['appearance']) == (component_id,'default',appearance), f'wrong emitted binding {name}')
            require(binding['source_revision'] == manifest['source']['tested_merge_sha'] and binding['capture_kind'] == 'native_app_screenshot' and binding['visual_review'] == 'pending' and binding['interaction_coverage'] == 'not_implied', f'rewritten emitted binding {name}')
        transform = asset['transform']
        require(set(transform) == {'crop','scale','resampling','encoding','ui_retouched'}, f'unknown transform {name}')
        require(transform['scale'] == 1 and transform['resampling'] is None and transform['encoding'] == 'lossless-webp' and transform['ui_retouched'] is False, f'unapproved transform {name}')
        crop = transform['crop']
        if crop is None:
            require(dimensions == (1206,2622), f'invalid full viewport {name}')
        else:
            require(isinstance(crop, list) and len(crop) == 4 and all(type(v) is int for v in crop), f'invalid crop {name}')
            left, top, right, bottom = crop
            require(0 <= left < right <= 1206 and 0 <= top < bottom <= 2622 and dimensions == (right-left,bottom-top), f'out-of-bounds crop {name}')
        if scope == 'screen-family':
            require(crop is None and source['test_identifier'] == 'LayeredKitPreviewUITests/testEighteenScreenTypesInLightAndDark()', f'wrong screen capture {name}')
    require(total <= MAX_TOTAL_BYTES, 'component image set exceeds budget')
    return len(assets)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=Path(__file__).resolve().parent.parent)
    args=parser.parse_args()
    try:
        count=verify(args.root)
    except (OSError, ValueError, KeyError, TypeError, struct.error) as error:
        print(error,file=sys.stderr)
        return 1
    print(f'Component image provenance passed: {count} exact native captures; independent visual acceptance is separate.')
    return 0

if __name__ == '__main__':
    sys.exit(main())
