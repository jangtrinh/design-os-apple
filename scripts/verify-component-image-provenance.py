#!/usr/bin/env python3
"""Verify the exact native component-catalog image set; does not establish visual acceptance."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

DIRECTORY = 'docs/assets/components'
MANIFEST_SHA256 = '9bc5f6bee51a27bf82c25dd18a1d963f2c40ca7295cd32d61bdab5c2470cbfc3'
ROUTES = {'confirmation','discovery','flat-collection','focused-task','freeform-editor','grouped-form','hero-collection','media-composer','media-detail','message-thread','native-presentation','onboarding','profile-detail','provider-host','record-detail','search-selection','status','utility-canvas'}
EXPECTED = {f'iphone-{route}-{theme}.webp' for route in ROUTES for theme in ('light','dark')}

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
    require(manifest['version'] == 1, 'unsupported version')
    require(manifest['source']['head_sha'] == 'adcf88a468a43ed1727c9c902ae5243423e4176e' and manifest['source']['run_id'] == 38087127370, 'wrong source revision or run')
    assets = manifest['assets']
    require(len(assets) == 36 and {a['file'] for a in assets} == EXPECTED, 'wrong asset inventory')
    total = 0
    for asset in assets:
        name = asset['file']
        data = regular(root, f'{DIRECTORY}/{name}').read_bytes()
        require(len(data) == asset['byte_size'] and 0 < len(data) <= 600000, f'invalid byte size {name}')
        total += len(data)
        require(hashlib.sha256(data).hexdigest() == asset['sha256'], f'hash mismatch {name}')
        require(len(data) >= 25 and data[:4] == b'RIFF' and data[8:16] == b'WEBPVP8L' and data[20] == 0x2f, f'not lossless WebP {name}')
        require(struct.unpack('<I', data[4:8])[0] == len(data) - 8, f'invalid WebP container size {name}')
        bits = struct.unpack('<I', data[21:25])[0]
        dimensions = ((bits & 0x3fff) + 1, ((bits >> 14) & 0x3fff) + 1)
        require(dimensions == (603, 1311) == (asset['width'],asset['height']), f'wrong dimensions {name}')
        require(asset['kind'] == 'native-ci-screenshot' and asset['source']['test_identifier'] == 'LayeredKitPreviewUITests/testEighteenScreenTypesInLightAndDark()', f'wrong capture source {name}')
        require(asset['transform'] == {'crop':None,'scale':0.5,'resampling':'Lanczos','encoding':'lossless-webp','ui_retouched':False}, f'unapproved transform {name}')
    require(total <= 7000000, 'component image set exceeds budget')
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
    print(f'Component image provenance passed: {count} exact native screen captures; independent visual acceptance is separate.')
    return 0

if __name__ == '__main__':
    sys.exit(main())
