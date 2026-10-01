# Apple Design OS

Apple Design OS is a SwiftUI design-system library for iOS, iPadOS, and macOS. It keeps
Apple-owned controls and interaction native, then adds semantic roles, typed profiles,
content-only components, native API recipes, and a searchable Gallery of instructional
reference pages that both people and AI agents can read.

> **Release state:** `0.1.0-rc.1` candidate on `main`. No version tag has been published yet;
> pin a branch or commit until the first tag lands.

Minimum platforms: iOS and iPadOS 17, macOS 14. Swift 6.2 toolchain, Swift Package Manager.
DESIGN:OS maintainer tooling is not required by package consumers.

## Add the package

In `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/jangtrinh/design-os-apple.git", branch: "main")
],
targets: [
  .target(name: "MyApp", dependencies: [
    .product(name: "DesignOSApple", package: "design-os-apple")
  ])
]
```

Or in Xcode choose **File > Add Package Dependencies**, paste the repository URL, and link
the `DesignOSApple` product to your target. `DesignOSAppleExtensions` and
`DesignOSAppleCatalog` are optional products for extension surfaces and catalog metadata.

The first compiling view is in [Getting Started](docs/getting-started.md). Its code block is
type-checked by `scripts/verify-consumer-quickstart.sh` against the built package.

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

## Browse the Gallery

Install [XcodeGen](https://github.com/yonaskolb/XcodeGen), then generate and open the native
Gallery:

```bash
xcodegen generate --spec Examples/DesignOSAppleGallery/project.yml \
  --project Examples/DesignOSAppleGallery
open Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj
```

Run `DesignOSAppleGallery-iOS` or `DesignOSAppleGallery-macOS`. The default route is the
searchable Catalog. Every Catalog story is an instructional reference page: stable AI
keyword, executable preview or native destination, concrete use/avoid/placement guidance,
copyable SwiftUI call site, ownership, availability, fallback, related stories, and source
path. Package-internal primitives remain browsable under **Implementation internals** but
point product code toward semantic components.

A specific admitted story or profile can be opened with launch arguments:

```text
--design-os-story <story-id>
--design-os-profile <profile-id>
```

Open **Examples** for six original, local-only two-screen mini apps that show native
SwiftUI composition in product-shaped contexts. They use fictional fixtures, SF Symbols, and
generated artwork; they are learning surfaces, not public runtime APIs or release catalog
entries.

### Catalog authority

- [`DesignOSReleaseCatalog`](Sources/DesignOSAppleCatalog/DesignOSReleaseCatalog.swift) is
  the typed release-story authority.
- The [catalog bundle `v2`](Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json)
  is a checked machine-readable projection for tools and AI agents, not a second authority.
  The `v1` artifact stays frozen for compatibility.
- The [local demo catalog](Examples/DesignOSAppleGallery/Generated/local-demo-catalog.v2.json)
  is a separate `localOnly` manifest for the mini apps. Tools must not merge its IDs into
  the release catalog or infer package API availability from it.

Maintainers follow the [catalog thumbnail workflow](docs/catalog-thumbnail-workflow.md) for
generated artwork and the
[reference reconstruction workflow](docs/reference-reconstruction-workflow.md) for new
research-driven mini apps.

## Verify the checkout

```bash
swift test
scripts/verify-release-candidate.sh
```

The release gate covers package tests, strict release compilation, formatting, DocC,
catalog drift, publication boundary, the consumer quickstart, and feasible Gallery
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

## OS 27 & iPhone Duo Intake

The September 2026 Apple platform announcements (iPhone Duo hardware architecture, iOS 27, iPadOS 27, macOS 27) are audited in the [iPhone Duo & OS 27 Platform Intake Report](docs/os27-intake-report.md). Authoritative knowledge units are maintained in [`docs/knowledge/`](docs/knowledge/) under the Universal Knowledge Markdown Contract (UKMC.v1). The intake tracks repository subsystem gap inventory (`Profile/`, `Tokens/`, `Components/`, `Recipes/`, `DesignOSApple.docc/`, `Examples/DesignOSAppleGallery/`), preserves strict package floors (iOS 17, iPadOS 17, macOS 14), and documents verified simulator specimen evidence.

## Project routes

- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Security](SECURITY.md)
- [Apple platform evolution](docs/apple-platform-evolution.md)
- [iPhone Duo & OS 27 Intake Report](docs/os27-intake-report.md)
- [Release process](RELEASING.md)
- [Changelog](CHANGELOG.md)

Original project software and documentation use the [MIT License](LICENSE). Apple Design
OS is independent and is not affiliated with, endorsed by, or sponsored by Apple Inc.
Apple platform names and trademarks belong to Apple Inc. Apple Design Resources, fonts,
symbols, template artwork, and other Apple-owned assets are not distributed under this
license.
