# Apple Design OS

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-F05138.svg?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![Platforms: iOS 17 | iPadOS 17 | macOS 14](https://img.shields.io/badge/Platforms-iOS%2017%20%7C%20iPadOS%2017%20%7C%20macOS%2014-0071e3.svg?style=flat)](Package.swift)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat)](LICENSE)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero-blue.svg?style=flat)](Package.swift)
[![State: 0.1.0-rc.1 untagged](https://img.shields.io/badge/State-0.1.0--rc.1%20(untagged)-gray.svg?style=flat)](RELEASING.md)

Apple Design OS is a SwiftUI design-system library for iOS, iPadOS, and macOS. It keeps
Apple-owned controls and interaction native, then adds semantic roles, typed profiles,
content-only components, native API recipes, and a searchable Gallery of instructional
reference pages that both people and AI agents can read.

> **Release state:** `0.1.0-rc.1` candidate on `main`. No version tag has been published yet;
> pin a branch or commit until the first tag lands.

Minimum platforms: iOS and iPadOS 17, macOS 14. Swift 6.2 toolchain, Swift Package Manager.
DESIGN:OS maintainer tooling is not required by package consumers.
Web documentation site: [https://jangtrinh.github.io/design-os-apple/](https://jangtrinh.github.io/design-os-apple/)

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

### Key specifications (6 facts)

- **Repository:** [`jangtrinh/design-os-apple`](https://github.com/jangtrinh/design-os-apple)
- **Requires:** iOS 17+, iPadOS 17+, macOS 14+ · Swift 6.2 · Zero external package dependencies
- **Interface:** Native SwiftUI Library (Swift Package Manager)
- **Transport / Protocol:** In-process Swift Package · DocC Documentation
- **Telemetry / Privacy:** Zero first-party telemetry or tracking in library; web documentation page loads external Shields badges and Buy Me a Coffee widget
- **License:** [MIT License](LICENSE)

### Honest boundary

- **Use when:** Building native SwiftUI apps for iOS 17+, iPadOS 17+, and macOS 14+ that need semantic roles, typed profiles, and adaptive recipes without third-party dependencies.
- **Avoid when:** Requiring cross-platform abstractions (Flutter/React Native), custom non-native rendering engines, or legacy deployments below iOS 17 / macOS 14.

### 3 Safe-use steps

1. **Add Package:** Link `DesignOSApple` via Swift Package Manager with zero external dependencies.
2. **Compose Natively:** Place `DesignOSListRow` inside native `List` or `NavigationSplitView`.
3. **Inject Profile:** Apply `.designOSProfile(.default)` once at a product subtree boundary.

### Practical verification verbs

- `build`: `swift build` — Compiles package in debug mode.
- `test`: `swift test` — Runs package unit tests (historically recorded 90 passed in baseline; 91 passed in debug configuration).
- `inspect`: `xcodegen generate --spec Examples/DesignOSAppleGallery/project.yml --project Examples/DesignOSAppleGallery` followed by `open Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj` (see [Browse the Gallery](#browse-the-gallery)) — Generates Xcode project (separate open command launches catalog).
- `verify`: `scripts/verify-release-candidate.sh` — Validates candidate release gate (historical baseline failed Swift 6.2.3 SIL crash; workaround avoids crash with strict release build passed).

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

## CalorieCam: native app dogfood

[CalorieCam](Examples/CalorieCam/README.md) is a separate iPhone/iPad/macOS example that
uses this design system for a photo-reference meal journal: choose or capture a photo,
review editable food estimates, and explicitly save a meal. Its initial offline mode uses
labeled sample data, not image recognition. Native build, simulator, camera and live-AI
verification must be reported separately; source availability is not runtime acceptance.

- [Native API lookup and coverage](docs/component-coverage.md): find a native API's
  existing story and evidence level without inventing a wrapper.
- [Latest Apple UI roadmap](docs/apple-ui-roadmap-2026-10.md): stable versus prerelease
  capabilities, including documented Duo additions pending SDK verification.
- [Mobbin research and interaction decisions](docs/caloriecam-mobbin-research.md).
- [Design-system organization](docs/design-system-organization.md): Design OS authority layers
  and a [machine-readable app-style index](docs/app-styles/editorial/manifest.json).
- [Reusable editorial app style](docs/reusable-app-style.md): opt-in shared palette,
  media rows, content surfaces, native button appearance and accessible media backdrops.
- [Luma visual reference evidence](docs/luma-style-reference.md): observed pixels, inferred
  geometry, native interaction mapping and explicit fidelity limits.

On a Mac with Xcode and XcodeGen, run `scripts/verify-caloriecam.sh` for core tests and
iPhone/iPad/macOS UI tests. This is a separate dogfood check and does not replace the
package release-candidate gate.

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

### Portable documentation and provenance checks

The documentation and provenance regression checks also run on Linux with Python 3:

```bash
python3 scripts/test-ukmc-verifier.py
python3 scripts/test-quickstart-parity.py
python3 scripts/verify-quickstart-parity.py
```

These checks reject malformed provenance and drift between the landing-page Swift example
and the Getting Started example. They do not compile SwiftUI or replace the macOS release
gate. The UKMC regression suite distinguishes local structural validation from canonical
knowledge-builder integration; a passing portable suite is not canonical-contract proof.

See [portable verification](docs/portable-verification.md) for dependency setup and scope.

### Managed design intent

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

## Implementation Specimens

Native navigation behavior verified on Apple platform simulators:
- [iPhone 17 Pro Portrait (iOS 26.2 build 23C54)](docs/specimens/specimen-iphone17pro-compact.png)
- [iPhone 17 Pro Landscape (iOS 26.2 build 23C54)](docs/specimens/specimen-iphone17pro-landscape.png)
- [iPad Pro 11-inch M5 Two-Column Split View (iPadOS 26.2 build 23C54)](docs/specimens/specimen-ipadpro-wide.png)
- [Specimens Manifest](docs/specimens/manifest.json)

## Project routes

- [Web Documentation Site](https://jangtrinh.github.io/design-os-apple/)
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
