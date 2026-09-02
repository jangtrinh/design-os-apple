#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
cd "$project_root"

swift run DesignOSAppleCatalogBundleTool check \
  --bundle-input Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json

print -- "Catalog bundle matches the compiled typed authority."
