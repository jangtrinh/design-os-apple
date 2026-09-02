# Apple Design OS

Apple Design OS is a SwiftUI design-system library for iOS, iPadOS, and macOS. It keeps
Apple-owned controls and interaction native, then adds semantic roles, typed profiles,
content-only components, native API recipes, and a searchable Gallery.

> **Release state:** local `0.1.0-rc.1` candidate. No public repository URL or tagged
> release exists yet. Add the package locally; do not invent a remote dependency URL.

Minimum platforms: iOS and iPadOS 17, macOS 14. Swift Package Manager builds the runtime.
DESIGN:OS maintainer tooling is not required by package consumers.

## Add the package locally

1. Clone or copy this repository beside your app.
2. In Xcode, choose **File > Add Package Dependencies > Add Local**.
3. Select this repository and link the `DesignOSApple` product to your target.
4. Import `DesignOSApple` and start with a native container.

The first compiling view is in [Getting Started](docs/getting-started.md). Its code block is
type-checked by `scripts/verify-consumer-quickstart.sh` against the built package.

## Browse the Gallery

Install [XcodeGen](https://github.com/yonaskolb/XcodeGen), then generate and open the native
Gallery:

```bash
xcodegen generate --spec Examples/DesignOSAppleGallery/project.yml \
  --project Examples/DesignOSAppleGallery
open Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj
```

Run `DesignOSAppleGallery-iOS` or `DesignOSAppleGallery-macOS`. The default route is the
searchable Catalog. Open **Examples** for original, local-only two-screen mini-apps that
show native SwiftUI composition in product-shaped contexts. These examples use fictional
fixtures and SF Symbols; they are learning surfaces, not public runtime APIs or release
catalog entries.

A specific admitted Catalog story can be opened with launch arguments:

Catalog artwork is generated and verified separately from the executable SwiftUI stories.
Maintainers should follow the [catalog thumbnail workflow](docs/catalog-thumbnail-workflow.md)
instead of drawing thumbnail plates in SwiftUI.

New research-driven mini apps follow the
[reference reconstruction workflow](docs/reference-reconstruction-workflow.md), which
keeps native ownership, clean-room provenance, source-bound screenshots, and independent
visual review as separate contracts.

Every Catalog story is an instructional reference page: stable AI keyword, executable preview or
native destination, concrete use/avoid/placement guidance, copyable SwiftUI call site, ownership,
availability, fallback, related stories, and source path. Package-internal primitives remain
browsable under **Implementation internals** but point product code toward semantic components.

```text
--design-os-story <story-id>
--design-os-profile <profile-id>
```

The complete typed release-story authority is
[`DesignOSReleaseCatalog`](Sources/DesignOSAppleCatalog/DesignOSReleaseCatalog.swift). The
[machine-readable catalog bundle](Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json)
is a checked projection for tools and AI agents, not a second catalog authority. The
previous `v1` artifact remains frozen for compatibility and is not current discovery authority. The
separate `DesignOSPilotCatalog` preserves the current owner-approved five-story dogfood evidence boundary;
it is not the public Gallery inventory.

The [local demo catalog](Examples/DesignOSAppleGallery/Generated/local-demo-catalog.v2.json)
is a separate `localOnly` manifest for six two-state mini apps. Its 12 live SwiftUI states
are composition examples, not copied screenshots or public package APIs. Tools must not
merge its IDs into the typed release catalog or infer package API availability from it.

## Choose the right API

- Put `DesignOSListRow` or `DesignOSSidebarRow` inside caller-owned native containers.
- Use `DesignOSColorRole`, `DesignOSTypographyRole`, and `DesignOSSurfaceRole` for semantic
  construction intent.
- Inject a validated `DesignOSProfile` once at a product subtree boundary.
- Call `Button`, `List`, `NavigationSplitView`, presentation modifiers, and extension APIs
  directly. The DocC recipes document their layout and accessibility contracts.

Start at the [DocC landing page](Sources/DesignOSApple/DesignOSApple.docc/DesignOSApple.md)
for runtime concepts. AI-assisted consumers should read [AI Usage](docs/ai-usage.md) before
generating an interface.

## Verify the checkout

```bash
scripts/verify-release-candidate.sh
```

This deterministic gate covers package tests, strict release compilation, formatting,
DocC, catalog drift, publication boundary, the consumer quickstart, and feasible Gallery
build/smoke checks. Passing it does not prove manual VoiceOver behavior, physical-device
behavior, visual taste, independent review, or owner acceptance. See
[Quality Evidence](docs/quality-evidence.md).

## Maintainer-only design management

`design/` is the DESIGN:OS management source of truth. `Sources/DesignOSApple/` is the
native runtime implementation. Maintainers changing managed design intent use `ui ds`;
consumers never need it:

```bash
ui ds status --dir .
ui ds context --strict --dir .
ui ds change-token <token.path> --value <value> --reason "<decision>" --dir .
```

Never hand-edit `design/design.tokens.json`. The DESIGN:OS persona is an aesthetic seed;
Apple documentation, platform APIs, and live behavior remain authoritative.

## Project routes

- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Security](SECURITY.md)
- [Apple platform evolution](docs/apple-platform-evolution.md)
- [Release process](RELEASING.md)
- [Changelog](CHANGELOG.md)

Original project software and documentation use the [MIT License](LICENSE). Apple Design
OS is independent and is not affiliated with, endorsed by, or sponsored by Apple Inc.
Apple platform names and trademarks belong to Apple Inc. Apple Design Resources, fonts,
symbols, template artwork, and other Apple-owned assets are not distributed under this
license.
