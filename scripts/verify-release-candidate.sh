#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}

"$project_root/scripts/test-publication-boundary.sh"
"$project_root/scripts/verify-publication-boundary.sh" --candidate
"$project_root/scripts/verify-swift-package.sh"
"$project_root/scripts/verify-consumer-quickstart.sh"
"$project_root/scripts/verify-catalog-bundle.sh"
"$project_root/scripts/verify-documentation.sh"
"$project_root/scripts/verify-gallery.sh"

print -- "Local release-candidate deterministic gates passed."
