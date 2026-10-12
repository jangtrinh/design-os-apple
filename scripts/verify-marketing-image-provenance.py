#!/usr/bin/env python3
"""Verify the exact reviewed public marketing image set, without network access.

Hashes bind these documentation assets to the reviewed CI export manifest. This
checks provenance integrity, not independent runtime acceptance or visual fidelity.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path
import struct
import sys

DIRECTORY = "docs/assets/marketing"
MANIFEST_SHA256 = "c109b1faa1b383fdbf58be22003eaea8c9ef9af8641356440ca510a8c5b77549"
EXPECTED = {
    "iphone-discovery-light.png", "iphone-discovery-dark.png",
    "iphone-media-composer-dark.png", "iphone-grouped-form-light.png",
    "iphone-message-thread-dark.png", "iphone-onboarding-light.png",
    "ipad-discovery-light.png", "macos-discovery-dark.png", "kit-overview.png",
}
CANDIDATE_SHA = "1898ce28861d642f57dccd88fd57afcbe3be5bb9"
RUN_ID = 38157622095
TESTED_MERGE_SHA = "f77ab0e051d22d9c80bc6bd24edf952ffb2bc430"
SOURCE_TREE_SHA = "d409c1deaa8c4f766916d728b20c53852214d09b"
SOURCE_GLOBS = ["Sources/DesignOSApple/**/*.swift", "Examples/LayeredKitPreview/App/**/*.swift"]
RESOURCE_FILES = ["Examples/CalorieCam/Resources/DemoMeal.png"]
ARTIFACT_IDS = {"iphone": 11709824406, "ipad": 11710600575, "macos": 11710826153}
ORIGINAL_JOBS = {"iphone": 114526372935, "ipad": 114526372932, "macos": 114526373030}
# Freshness deliberately ignores docs and UITest-only diagnostics. A changed,
# added or removed runtime/app Swift source requires newly reviewed native evidence.
def freshness_files(root):
    return {p.relative_to(root).as_posix() for pattern in SOURCE_GLOBS for p in root.glob(pattern)} | set(RESOURCE_FILES)


def verify_freshness(root, manifest):
    freshness = manifest.get("runtime_freshness", {})
    require(freshness.get("source_head_sha") == CANDIDATE_SHA, "wrong freshness source")
    require(freshness.get("source_globs") == SOURCE_GLOBS and freshness.get("resource_files") == RESOURCE_FILES, "unreviewed freshness scope")
    pins = freshness.get("files", [])
    paths = [entry["path"] for entry in pins]
    require(len(paths) == len(set(paths)) and set(paths) == freshness_files(root), "runtime freshness inventory changed")
    for pin in pins:
        data = regular(root, pin["path"]).read_bytes()
        require(hashlib.sha256(data).hexdigest() == pin["sha256"], f"runtime source changed; refresh native marketing evidence: {pin['path']}")



def require(condition, message):
    if not condition:
        raise ValueError(f"E_MARKETING_IMAGE: {message}")


def regular(root, relative):
    target = root / relative
    require(target.is_file() and not target.is_symlink(), f"missing or nonregular {relative}")
    require(target.resolve() == target, f"symlink-resolved {relative}")
    return target


def verify(root):
    root = Path(root).resolve(strict=True)
    directory = root / DIRECTORY
    require(directory.is_dir() and not directory.is_symlink(), "missing or symlinked marketing directory")
    require(directory.resolve() == directory, "symlinked marketing ancestor")
    require({p.name for p in directory.iterdir()} == EXPECTED | {"manifest.json"}, "unexpected or missing marketing file")
    raw = regular(root, f"{DIRECTORY}/manifest.json").read_bytes()
    require(hashlib.sha256(raw).hexdigest() == MANIFEST_SHA256, "unreviewed provenance manifest")
    manifest = json.loads(raw)
    require(manifest.get("version") == 2, "unsupported manifest version")
    source = manifest.get("source", {})
    require(source.get("repository") == "jangtrinh/design-os-apple", "wrong source repository")
    require(source.get("head_sha") == CANDIDATE_SHA, "wrong source commit")
    require(source.get("run_id") == RUN_ID, "wrong source CI run")
    require(source.get("run_url") == f"https://github.com/jangtrinh/design-os-apple/actions/runs/{RUN_ID}", "wrong source run URL")
    require(source.get("tested_merge_sha") == TESTED_MERGE_SHA and source.get("source_tree_sha") == SOURCE_TREE_SHA and source.get("run_attempt") == 1, "wrong tested source tree or attempt")
    verify_freshness(root, manifest)
    assets = manifest.get("assets", [])
    require(len(assets) == len(EXPECTED), "wrong asset count")
    require({a.get("file") for a in assets} == EXPECTED, "duplicate or unexpected asset entry")
    total = 0
    for asset in assets:
        name = asset["file"]
        expected_kind = "screenshot-composition" if name == "kit-overview.png" else "native-ci-screenshot"
        require(asset.get("kind") == expected_kind, f"wrong source kind: {name}")
        if expected_kind == "native-ci-screenshot":
            original = asset.get("source", {})
            platform = "iphone" if name.startswith("iphone-") else "ipad" if name.startswith("ipad-") else "macos"
            require(original.get("artifact_id") == ARTIFACT_IDS[platform], f"wrong source artifact: {name}")
            require(original.get("artifact_name") == f"layered-kit-{platform}-test-results", f"wrong artifact name: {name}")
            require(original.get("test_identifier") == "LayeredKitPreviewUITests/testEighteenScreenTypesInLightAndDark()", f"wrong capture test: {name}")
            require(original.get("head_sha") == CANDIDATE_SHA and original.get("tested_merge_sha") == TESTED_MERGE_SHA, f"obsolete asset source: {name}")
            require(original.get("run_attempt") == 1 and original.get("job_id") == ORIGINAL_JOBS[platform], f"wrong original job: {name}")
            require(original.get("test_result") == "Success" and original.get("original_payload_equals_export") is True and original.get("original_payload_sha256") == original.get("sha256"), f"unverified native payload: {name}")
            require(original.get("binding_kind") == "named_native_attachment" and original.get("generic_json_binding_present") is False, f"fabricated generic binding: {name}")
            require(asset.get("platform") == platform and asset.get("state") == "populated" and asset.get("ui_retouched") is False, f"wrong state or retouching: {name}")
            route = name.removeprefix(platform + "-").removesuffix(".png")
            family, appearance = route.rsplit("-", 1)
            require(asset.get("component_id") == "screen/" + family and asset.get("appearance") == appearance, f"wrong native case: {name}")
            if platform == "macos":
                require(asset.get("crop") == [61,142,963,595] and asset.get("resize") is None and (asset.get("width"),asset.get("height")) == (902,453), f"unapproved Mac transform: {name}")
            else:
                dimensions = (603,1311) if platform == "iphone" else (1032,1376)
                require(asset.get("crop") is None and asset.get("resize") == {"scale":0.5,"resampling":"Lanczos"} and (asset.get("width"),asset.get("height")) == dimensions, f"unapproved simulator transform: {name}")
            for key in ("sha256", "artifact_sha256", "manifest_sha256", "database_sha256", "recovered_evidence_sha256"):
                require(re.fullmatch(r"[a-f0-9]{64}", original.get(key, "")), f"missing source hash: {name}/{key}")
        else:
            inputs = asset.get("source_files", [])
            require(inputs and set(inputs) <= EXPECTED - {name}, "unadmitted composition input")
            placements = asset.get("composition", {}).get("placements", [])
            require(len(placements) == len(inputs) == len(set(inputs)) and {p.get("file") for p in placements} == set(inputs), "composition placement mismatch")
            require((asset.get("width"),asset.get("height")) == (2000,1000), "wrong hero dimensions")
            require(asset.get("composition", {}).get("ui_retouched") is False and asset["composition"].get("resampling") == "Lanczos", "unapproved hero transform")
            require(set(asset.get("source_file_sha256", {})) == set(inputs), "missing hero input hashes")
            for name_in in inputs:
                require(hashlib.sha256(regular(root, f"{DIRECTORY}/{name_in}").read_bytes()).hexdigest() == asset["source_file_sha256"][name_in], f"stale hero source: {name_in}")
            for placement in placements:
                x,y,w,h = (placement.get(key) for key in ("x","y","width","height"))
                require(all(type(v) is int for v in (x,y,w,h)) and 0 <= x < x+w <= 2000 and 0 <= y < y+h <= 1000, "hero placement outside canvas")
        data = regular(root, f"{DIRECTORY}/{name}").read_bytes()
        total += len(data)
        require(0 < len(data) <= 1000000, f"image exceeds bounded size: {name}")
        require(len(data) == asset.get("byte_size"), f"byte count mismatch: {name}")
        require(hashlib.sha256(data).hexdigest() == asset.get("sha256"), f"image hash mismatch: {name}")
        require(data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR", f"not a PNG: {name}")
        width, height = struct.unpack(">II", data[16:24])
        require((width, height) == (asset.get("width"), asset.get("height")), f"dimension mismatch: {name}")
        require(0 < width <= 10000 and 0 < height <= 10000, f"invalid dimensions: {name}")
    require(total <= 4000000, "marketing image set exceeds 4 MB budget")
    return len(assets)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    args = parser.parse_args()
    try:
        count = verify(args.root)
    except (OSError, ValueError, KeyError, TypeError, struct.error) as error:
        print(error, file=sys.stderr)
        return 1
    print(f"Marketing image provenance passed: {count} exact reviewed images (runtime acceptance is separate).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
