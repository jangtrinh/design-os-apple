# iPhone Duo & OS 27 Platform Intake Report

> **Date:** 2026-10-01  
> **Author:** Gemini 3.8 Flash (High)  
> **Status:** Complete Intake Audit, UKMC Knowledge Units, and Executed Specimen Verification  
> **Branch:** `audit/iphone-duo-os27` (base commit `31e49d2929d24fedc1da81d6a447fd03b7180631`)  
> **Knowledge-Builder Base:** `db18f80f754b7901cbf7d9b674dd72a0853b3f2b` (read-only)  

---

## 1. Executive Summary & Verification Context

This intake report provides an authoritative, evidence-backed intake audit of Apple's September 2026 platform announcements—specifically the **iPhone Duo** foldable hardware architecture and the **OS 27** family (iOS 27, iPadOS 27, macOS 27)—for integration into `DesignOSApple`.

### Model & Runtime Environment Evidence
- **Model Resolution:** Gemini 3.8 Flash (High) is selected and resolved before generation (evidenced in CLI startup log via `model_resolver.go:93` resolving `gemini-3.8-flash-high` and `model_config_manager.go:327` propagating override `Gemini 3.8 Flash (High)`); served-model transcript is unavailable from within the runtime environment.
- **Installed Toolchain:** Xcode 26.2 (Apple Swift version 6.2.3 `swiftlang-6.2.3.3.21 clang-1700.6.3.2`, macOS 26.5.2 build 25F84).
- **Installed Simulators:** iOS 18.6, iOS 26.1, iOS 26.2. No iOS 27 or iPhone Duo simulator runtime exists in the local environment.
- **Package Floor Constraint:** Minimum platforms remain strictly **iOS 17, iPadOS 17, macOS 14**. The annual intake must not prematurely lift package floors or invent unsupported SDK APIs.

---

## 2. Primary Sources & Cryptographic Corpus

All primary sources were fetched directly from Apple endpoints on 2026-10-01, saved to the local corpus directory (`docs/corpus/`), and verified via SHA256 hashes against `docs/corpus/manifest.json`:

| Source Identifier | URI / Endpoint | Modality | Size (Bytes) | SHA256 Digest |
|---|---|---|---|---|
| `apple-iphone-duo-landing` | `https://www.apple.com/iphone-duo/` | Web HTML | 723,842 | `4fb160f316988bf1ef823f3d2dd40c6688e5f96c8afac49c1e4ac8f0e92eab2a` |
| `apple-newsroom-iphone-duo` | `https://www.apple.com/newsroom/2026/09/apple-unveils-iphone-duo/` | Web HTML | 341,663 | `f90367a10319b84e71d0333396394db65bbc2d99a92ae06f98b91b05a2829eed` |
| `apple-os-ios` | `https://www.apple.com/os/ios/` | Web HTML | 272,113 | `ebb7bb9059975be8400c58e015cb3147946d61f0b22dc2dfbac0edbdead4c641` |
| `apple-os-ipados` | `https://www.apple.com/os/ipados/` | Web HTML | 267,672 | `0da1d9fbd1483a019d4d54dfd6c2734dba429991e897bcafce76cd745107715a` |
| `apple-os-macos` | `https://www.apple.com/os/macos/` | Web HTML | 257,153 | `d038f9ae5ed6c9580d60ed38765a92e34720d47e166a53f9a3e442d9ca68060b` |
| `developer-macos-27-release-notes` | `https://developer.apple.com/tutorials/data/documentation/macos-release-notes/macos-27-release-notes.json` | DocC JSON | 146,633 | `5c77ef7cc0c4e59d8a7fa6a3132729ec6c58492f11f49f168006a72a25bc6fdd` |
| `developer-ios-ipados-27-release-notes` | `https://developer.apple.com/tutorials/data/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes.json` | DocC JSON | 152,731 | `da7aaaa3899ee160e0a93a0d22b6b87b32b676121c341588fcc7415e32b9e834` |
| `developer-xcode-27-release-notes` | `https://developer.apple.com/tutorials/data/documentation/xcode-release-notes/xcode-27-release-notes.json` | DocC JSON | 140,916 | `d2aa54180e826b74909605ce5958ac4718e00201c6ec9c7f5f4d10859e848268` |
| `apple-hig-layout` | `https://developer.apple.com/tutorials/data/design/human-interface-guidelines/layout.json` | DocC JSON | 84,939 | `d41f32ddf76c597f0edd54eac361fa294a8736cfc4ccc627d1709fe092ed7267` |
| `developer-swiftui-navigationsplitview` | `https://developer.apple.com/tutorials/data/documentation/swiftui/navigationsplitview.json` | DocC JSON | 49,127 | `3b6912aa55406caeb19038399b3de8d693e4619a79c966b305b01189779d6443` |

---

## 3. Source-Backed Capability Matrix

To prevent conflating marketing claims with verified software APIs, capabilities are classified across explicit disposition statuses:
- **Announced (Hardware / Marketing):** Hardware specifications and marketing claims announced in September 2026. Pre-orders begin October 16, 2026; availability begins October 23, 2026. (As of October 1, 2026, status is Announced; not yet shipping).
- **API Documented (Local SDK/Runtime Unavailable):** Primary developer documentation or SDK release notes verified in DocC JSON with Apple issue anchors. (Not blanket-labeled as beta unless Apple explicitly identifies beta).
- **Executed Native Specimen:** Real executed SwiftUI specimen executed in the Gallery app on real simulator runtimes.
- **Scoped Exclusions:** Platforms outside library scope (visionOS, tvOS, watchOS).

| Feature / Capability | Source Category | Primary Anchor / Evidence Source | Disposition Status | Design OS Architectural Assessment |
|---|---|---|---|---|
| **iPhone Duo Foldable Hardware** | Hardware / Marketing | Apple Newsroom (`f90367a1...`), Product Landing (`4fb160f3...`) | Announced (Pre-order Oct 16, Availability Oct 23) | Grade 5 titanium, 100+ component precision hinge, Star White & Night Sky colors. Hardware boundary. |
| **Dual Aspect-Ratio Displays** | Hardware / Marketing | iPhone Duo Landing (`4fb160f3...`) | Announced | Inner display (largest iPhone display) and outer cover display (90% of iPhone 18 Pro) share identical proportional aspect ratio for visual continuity. |
| **Split View Multitasking on iPhone** | System / Windowing | Apple Newsroom (`f90367a1...`) | Announced (System-Owned) | System window management allowing two apps side-by-side. Applications must not attempt to own or mock system-level multi-app window management. |
| **Continuous Resizability & Orientation** | UIKit SDK | iOS 27 Release Notes `(166422120)`, `(178558224)`, `(178560235)` | API Documented (Local SDK/Runtime Unavailable) | Supported interface orientations is no longer a condition for continuous resizability. Scenes receive continuous resize updates on iPad and iPhone Mirroring. |
| **Mandatory Launch Screen** | App Store / UIKit | iOS 27 Release Notes `(168247372)` | API Documented (Local SDK/Runtime Unavailable) | Apps linked against 27.0 SDK must declare `UILaunchStoryboardName`, `UILaunchStoryboards`, `UILaunchScreen`, or `UILaunchScreens` in `Info.plist` or face App Store intake rejection (enforcement begins when App Store accepts 27.0 SDK submissions). |
| **SwiftUI TabsPickerStyle** | SwiftUI SDK | iOS 27 Release Notes `(173211711)` | API Documented (Local SDK/Runtime Unavailable) | Segmented picker semantic role tagged as "tabs" for VoiceOver with distinct visual appearance on macOS, separating navigation from value picking. |
| **SwiftUI textInputBorderShape & .bordered** | SwiftUI SDK | iOS 27 Release Notes `(173362083)` | API Documented (Local SDK/Runtime Unavailable) | Customizable border shape for text input controls; soft deprecation of `.squareBorder` / `.roundedBorder`. |
| **SwiftUI Concentric Corner Radii** | SwiftUI SDK | iOS 27 Release Notes `(177185166)` | API Documented (Local SDK/Runtime Unavailable) | `GeometryProxy.concentricCornerRadii` exposes outer container concentric radii offsets. |
| **AppKit NSMenuItem Image Hiding** | AppKit SDK | macOS 27 Release Notes `(170477566)` | API Documented (Local SDK/Runtime Unavailable) | Menu bar & context menus hide symbol images by default; non-symbol images remain visible. Governed by `NSMenuItem.preferredImageVisibility` for macOS 26+ linked apps. |
| **UIKit Menu Element Image Visibility** | UIKit SDK | iOS 27 Release Notes `(170479084)` | API Documented (Local SDK/Runtime Unavailable) | On iPadOS and macOS Catalyst, menu element images hidden by default. Governed by `UIMenuElement.preferredImageVisibility`. |
| **AppKit NSSegmentedControl Tabs Role** | AppKit SDK | macOS 27 Release Notes `(162577742)` | API Documented (Local SDK/Runtime Unavailable) | Semantic tabs role for segmented controls and toolbar item groups (`NSToolbarItemGroupRole`). |
| **AppKit NSRefreshController** | AppKit SDK | macOS 27 Release Notes `(160867808)` | API Documented (Local SDK/Runtime Unavailable) | Native pull-to-refresh for `NSScrollView`. |
| **AppKit Window Chrome Overhang** | AppKit SDK | macOS 27 Release Notes `(180962967)` | API Documented (Local SDK/Runtime Unavailable) | `NSTitlebarAccessoryViewController` is permitted to draw outside its bounds by default for apps linked on macOS 27.0 or later. |
| **HIG Adaptability & Size Classes** | Apple Design Guidelines | HIG Layout JSON (`alert-date: 2026-09-09`, `d41f32dd...`) | Verified Guidance | Layout by size classes (`horizontalSizeClass`), not physical device type or orientation; preserve functionality as size classes change dynamically; respect safe areas. |
| **Native SwiftUI NavigationSplitView Specimen** | SwiftUI Architecture | SwiftUI DocC JSON (`3b6912aa...`), Gallery App | Executed Native Specimen | Uses native SwiftUI `NavigationSplitView` with caller-owned selection state and preserved `TabView` mode in `NativeNavigationTabsAndToolbarsRecipeGallery`, presented in an isolated modal presentation in the Gallery app. Automatically collapses to single stack on iPhone compact, expands to 2-column sidebar on iPad wide. |
| **watchOS / tvOS / visionOS 27 Updates** | External Platforms | `Package.swift` platform declarations (`.iOS(.v17), .macOS(.v14)`) | Scoped Exclusion | Out of scope for package platforms (iOS, iPadOS, macOS only). |

---

## 4. UKMC Schema Discrepancy & Relationship Extension

### Schema Discrepancy Analysis
An inspection of `knowledge-builder` reveals an important discrepancy between documentation and executable code:
- **Canonical Documentation (`master-contract-ukmc.md`):** Documents YAML frontmatter using the key `source:`.
- **Executable Contract (`src/knowledge_builder/contract.py`):** The serialization method `UniversalKnowledgeUnit.to_markdown()` emits frontmatter using the key `source_attribution:` with subfields `uri`, `modality`, `sha256`, `captured_at`, and `license`.
- **Decision:** As instructed, we follow the **executable contract** (`source_attribution:`), ensuring automated validation and programmatic parsing via `knowledge_builder.contract`.

### Entity Relationships Extension
The canonical `UKMC.v1` specification defines metadata and source attribution but does not specify a standardized graph relationship syntax. To preserve strict standards without inventing canonical fields, we define an explicitly named extension:
```yaml
# Extension: UKMC.v1 relationship extension (non-canonical linked units)
relationships:
  linked_units:
    - id: "ios27-adaptive-multitasking-and-splitview"
      relationship: "complements"
```

### Knowledge Base Validation: Canonical Shallow Lint vs. Strict Local Schema & Provenance Validation
The knowledge base in `docs/knowledge/` consists of 4 complete units:
1. `iphone-duo-hardware-and-postures.md`
2. `ios27-adaptive-multitasking-and-splitview.md`
3. `macos27-appkit-menu-and-navigation-evolution.md`
4. `swiftui-os27-navigation-and-input-updates.md`

- **Canonical Shallow Lint / Index:** All 4 units pass canonical `knowledge_builder.cli lint` and compile via `knowledge_builder.cli index`. Canonical `cli.py` mandatory lint strings check exactly: `## Purpose`, `## When to Use / When NOT`, `## Core Knowledge Content`, and `## Failure Modes`, and require provenance substring `<!-- ease:source`. The canonical CLI `index` ALWAYS emits the exact literal string `"placeholder-hash"` (line 108 of `src/knowledge_builder/cli.py`) by contract specification, rather than deriving from offline or network mode.
- **Strict Local Schema & Provenance Extension Validation:** Our repository verifier (`scripts/verify-ukmc-corpus.py`) separately invokes the canonical Python contract validator (`UniversalKnowledgeUnit.validate()`) and layers strict local provenance and relationship graph extensions:
  - Exact cryptographic hash verification: SHA256 digests in UKMC frontmatter must match real manifest digests computed programmatically from corpus files.
  - Strict enum validation for `trust_tier` (`primary_source`, `secondary_analysis`, `untrusted_external`) and `modality` (`docc_json`, `web_html`, etc.) with zero silent coercion.
  - Strict boolean validation for `quarantine.is_external_untrusted` (rejecting arbitrary strings).
  - Strict ISO 8601 aware timestamp validation matching manifest metadata.
  - Fail-closed verification if canonical `knowledge-builder` is unavailable unless `--allow-fallback` is declared.
  - Guarantee that `--check` mode runs read-only without mutating artifacts, while strictly verifying that existing `docs/knowledge/index.strict.json` matches freshly computed normalized entries and current file SHA256 hashes.
  - **Automated Red-Probe Test Suite:** 15 automated red-probe unit tests in `scripts/test-ukmc-verifier.py` (including stale-index tamper and healing tests) execute and pass in 0.190s.

### Repository Gap Inventory by Subsystem Path

To track exact repository status against the OS 27 and iPhone Duo intake findings, the following inventory categorizes gaps across canonical repository paths based on actual files and symbols:

1. `Sources/DesignOSApple/Profile/`
   - **Current Status:** Foundation design-language profile architecture (`DesignOSProfile.swift`, `DesignOSTypographyProfile.swift`, `DesignOSSpacingProfile.swift`, `DesignOSRadiusProfile.swift`, `DesignOSSemanticColorProfile.swift`, `DesignOSSurfaceProfile.swift`, `DesignOSAccessibilityPolicy.swift`, `DesignOSProfileEnvironment.swift`). These represent product-level semantic customization containers, not hardware device specifications.
   - **Intake Gap:** While the Apple Newsroom corpus establishes physical display diagonals (7.6-inch inner display and 5.4-inch outer cover display), exact logical point bounds, coordinate space, aspect-ratio point metrics, and foldable posture metrics (e.g. tabletop/crease coordinates) remain unverified in developer SDKs and pending local runtime availability (hardware is announced, pre-orders Oct 16, 2026; availability Oct 23, 2026).
   - **Resolution & Policy:** The repository strictly avoids inventing speculative point bounds or synthetic hardware profiles. Applications adapt across form factors and foldable postures via native SwiftUI dynamic size classes (`horizontalSizeClass`) and safe area insets.

2. `Sources/DesignOSApple/Tokens/`
   - **Current Status:** Foundation semantic design token roles: `DesignOSColorRole.swift`, `DesignOSTypographyRole.swift`, `DesignOSSurfaceRole.swift`.
   - **Intake Gap:** OS 27 SDK platform styling additions: `GeometryProxy.concentricCornerRadii` `(177185166)`, `textInputBorderShape` `(173362083)`, and toolbar tab role semantics `(173211711)`.
   - **Resolution & Policy:** Documented in UKMC units. New platform styling APIs in OS 27 are documented native recipe concerns, not automatically package-token additions. Package floors remain strictly at iOS 17+, iPadOS 17+, macOS 14+; integration of OS 27 SDK symbols is deferred until compiler/SDK availability.

3. `Sources/DesignOSApple/Components/`
   - **Current Status:** Content-only row primitives: `DesignOSListRow.swift` and `DesignOSSidebarRow.swift`. (Native interactive controls like `Button`, `Menu`, `Picker` belong in `Recipes/`).
   - **Intake Gap:** macOS AppKit menu item image hiding behavior (`NSMenuItem.preferredImageVisibility` macOS 26+ linked `170477566`), `NSRefreshController` `(160867808)`, and UIKit menu element image visibility (`UIMenuElement.preferredImageVisibility` `170479084`).
   - **Resolution & Policy:** Component primitives remain focused on caller-owned content layout. Platform menu and scroll behaviors are tracked as documented platform evolutions for future compiler/SDK support.

4. `Sources/DesignOSApple/Recipes/` & `Sources/DesignOSApple/DesignOSApple.docc/`
   - **Current Status:** Recipes covering native Apple controls (`NativeNavigationTabsAndToolbarsRecipe.swift`, `NativeButtonAndToolbarActionRecipe.swift`, `NativeMenuContextAndEditActionsRecipe.swift`, etc.) accompanied by DocC instructional documentation.
   - **Intake Gap:** Guidance on adaptive multitasking and multi-window environments.
   - **Resolution & Policy:** NavigationSplitView DocC does not mandate querying geometric bounds or size classes manually; updated guidance recommends native `NavigationSplitView` adaptation (available since iOS 16 / macOS 13) to automatically handle compact single-column vs regular multi-column transitions.

5. `Examples/DesignOSAppleGallery/`
   - **Current Status:** Interactive gallery catalog demonstrating recipes and dogfood stories.
   - **Implementation & Visual Verification:** Native `NavigationSplitView` recipe implemented in `NativeNavigationTabsAndToolbarsRecipeGallery.swift` with caller-owned selection and segmented mode switch preserving `TabView` coverage. Presented in isolated native modal presentation (`.fullScreenCover` on iOS / `.sheet` on macOS) to avoid UIKit split-controller suppression inside navigation stacks. Verified via automated UI tests (`DesignOSAppleGalleryStoryUITests`).

---

## 5. Executed Specimen & Visual Evidence

Per repository architecture boundaries, adaptive navigation is implemented through native SwiftUI `NavigationSplitView` with caller-owned selection state (`NativeNavigationTabsAndToolbarsRecipeGallery.swift` in `Examples/DesignOSAppleGallery` and tested via `navigationSplitViewAdaptiveContract` in `Tests/DesignOSAppleTests/NativeNavigationTabsAndToolbarsRecipeTests.swift`). This respects Apple's Human Interface Guidelines by adapting layout dynamically based on available horizontal size class (`compact` vs `regular`) without inventing custom layout primitives or hardcoding display thresholds.

### Isolated Source Build & Provenance Evidence
To ensure exact build provenance from this isolated checkout:
- **Source Base SHA:** `31e49d2929d24fedc1da81d6a447fd03b7180631`
- **Build Command:** `xcodebuild -project Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj -scheme DesignOSAppleGallery-iOS -destination "platform=iOS Simulator,name=iPhone 17 Pro" -derivedDataPath <task-derived-data> build`
- **Launch Command with Typed Story Route:** `xcrun simctl launch <device> com.jang.designos.apple.gallery --design-os-story native.navigation-tabs-toolbars`

### Executed Interactive Specimen Screenshot Evidence
Interactive screenshots of the task application were captured from real executed simulator runtimes via automated XCTest UI test harnesses (using `XCUIApplication.screenshot()` for compact portrait and tablet wide layouts, and `XCUIScreen.main.screenshot()` for landscape orientation) and are maintained as repository-owned assets in [`docs/specimens/`](specimens/) accompanied by [`docs/specimens/manifest.json`](specimens/manifest.json):

| Specimen Asset | Device / Runtime | Resolution (Encoded / Display) | Byte Size | SHA-256 Digest | Layout & Provenance Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [specimen-iphone17pro-compact.png](specimens/specimen-iphone17pro-compact.png) | iPhone 17 Pro / iOS 26.2 Simulator (build 23C54) | 1206 x 2622 px / 1206 x 2622 px (EXIF 1) | 111,150 bytes | `9d61d18dad925c7d8723a09fd40ace8d99c30e1fa51c329cf512535d26210717` | Compact single-column navigation stack presenting Library detail pane with back affordance and caller-owned selection state. Captured 2026-10-01. |
| [specimen-iphone17pro-landscape.png](specimens/specimen-iphone17pro-landscape.png) | iPhone 17 Pro / iOS 26.2 Simulator (build 23C54) | 1206 x 2622 px / 2622 x 1206 px (EXIF 8) | 124,177 bytes | `a158da7780b61d45710c4f4bbce090ef0c54a33edf5d4148d41c450c4b21eb2d` | Rotated landscape presentation displaying full-width detail canvas, back button, and caller-owned selection after stable rotation. Captured 2026-10-01. |
| [specimen-ipadpro-wide.png](specimens/specimen-ipadpro-wide.png) | iPad Pro 11-inch (M5) / iPadOS 26.2 Simulator (build 23C54) | 1668 x 2420 px / 1668 x 2420 px (EXIF 1) | 140,022 bytes | `2ed549e7d66e4b6c4d3be95aea0c4738704deb591b1d5eb5051c6344c223292a` | Regular horizontal size class two-column persistent split view with sidebar navigation list and active detail canvas. Captured 2026-10-01. |

1. **Compact Phone Layout (Single-Column Collapsed Navigation - Library Detail):**
   - **Relative Asset Link:** [`docs/specimens/specimen-iphone17pro-compact.png`](specimens/specimen-iphone17pro-compact.png)
   - **Device & OS:** iPhone 17 Pro, iOS 26.2 Simulator (build 23C54)
   - **Capture Method:** XCTest (`XCUIApplication.screenshot()`)
   - **Resolution:** 1206 x 2622 px (111,150 bytes, SHA256: `9d61d18dad925c7d8723a09fd40ace8d99c30e1fa51c329cf512535d26210717`)
   - **UI State:** Collapsed single-column navigation stack presenting the selected detail pane ("Library") with caller-owned selection state displayed and back navigation affordance.

2. **Wide Tablet Layout (Two-Column Persistent Split View - Portrait):**
   - **Relative Asset Link:** [`docs/specimens/specimen-ipadpro-wide.png`](specimens/specimen-ipadpro-wide.png)
   - **Device & OS:** iPad Pro 11-inch (M5), iPadOS 26.2 Simulator (build 23C54)
   - **Capture Method:** XCTest (`XCUIApplication.screenshot()`)
   - **Resolution:** 1668 x 2420 px (140,022 bytes, SHA256: `2ed549e7d66e4b6c4d3be95aea0c4738704deb591b1d5eb5051c6344c223292a`)
   - **UI State:** Persistent two-column split view displaying sidebar navigation list alongside active detail canvas with caller-owned selection state preserved.

3. **Compact Phone Landscape Layout (Rotated Full-Width Detail View):**
   - **Relative Asset Link:** [`docs/specimens/specimen-iphone17pro-landscape.png`](specimens/specimen-iphone17pro-landscape.png)
   - **Device & OS:** iPhone 17 Pro, iOS 26.2 Simulator (build 23C54)
   - **Capture Method:** XCTest (`XCUIScreen.main.screenshot()`)
   - **Resolution:** 2622 x 1206 px displayed orientation (IHDR 1206 x 2622 with EXIF Orientation 8 metadata; 124,177 bytes, SHA256: `a158da7780b61d45710c4f4bbce090ef0c54a33edf5d4148d41c450c4b21eb2d`)
   - **UI State:** Rotated landscape presentation displaying full-width detail canvas, back navigation button, dismiss button, and caller-owned selection state after stable orientation transition.

### Attribution & Platform Rights Notice

These specimen screenshots are repository-generated implementation artifacts demonstrating native SwiftUI navigation behavior on Apple platform simulators. Apple platform visual styles, UI components, and SF Symbols are proprietary to Apple Inc. and depicted here for technical reference and interoperability demonstration only. They are distinguished from third-party or Apple official reference imagery and are not subject to blanket MIT code licensing.

### Rotation Diagnostic Classification & Strict Task 1470 Evidence

To establish exact provenance and avoid conflating harness test failures with layout defects, the rotation behavior was analyzed across strict failure evidence and bounded diagnostic runs:

- **Strict Task 1470 Failure Record:**
  - Test: `testNativeNavigationAdaptiveSplitViewSelectionAndRotation` in `DesignOSAppleGalleryStoryUITests.swift`.
  - Source lines: 89 and 103.
  - Failure: `XCTAssertEqual` failed: `XCTWaiterResult(rawValue: 2)` (`timedOut`) != `XCTWaiterResult(rawValue: 1)` (`completed`).
  - Expectation at Line 89: Landscape geometry wait (`width > height`), timeout 5.0s.
  - Expectation at Line 103: Restored portrait geometry wait (`height > width`), timeout 5.0s.
  - Original xcresult status: The original test result bundle is unavailable at the historical path due to rolling Xcode test log rotation across subsequent runs.
  - Private evidence retention: Historical task 1470 execution log, rejected diagnostic PNG attachments, and final test run xcresult bundles are preserved privately in companion review evidence outside the repository.

- **Rotation Diagnostic Classification (Observation vs. Inference):**
  - **Observed Test Evidence:** In historical task 1470, string-keypath predicate waits (`NSPredicate(format: "frame.size.width > frame.size.height")` and `"frame.size.height > frame.size.width"`) on `app.windows.firstMatch` timed out after 5.0s (`XCTWaiterResult(rawValue: 2)`), while the test log recorded the active window at `{{0.0, 0.0}, {874.0, 402.0}}` in landscape and `{{0.0, 0.0}, {402.0, 874.0}}` in portrait. Diagnostic PNGs taken with `app.screenshot()` exhibited top-half black clipping. In diagnostic task 1700 (`testNativeNavigationAdaptiveSplitViewRotationDiagnostics`), replacing string keypaths with typed block predicates (`NSPredicate { _, _ in app.windows.firstMatch.frame.width > app.windows.firstMatch.frame.height }`) completed cleanly in ~2.2s (`XCTWaiterResult.completed`), and real native `XCUIScreen.main.screenshot()` captured a fully rendered, unclipped landscape specimen (`docs/specimens/specimen-iphone17pro-landscape.png`). Orientation was reliably restored to portrait.
  - **Layout Scope Clarification:** On iPhone, rotated landscape orientation remains a compact horizontal size class, presenting a single-column full-width detail view rather than expanding into a two-column split view (two-column split view requires a regular horizontal size class, as executed and verified on iPad Pro 11-inch).
  - **Inferred Mechanism:** The evidence points to a string-keypath / harness observation mismatch on `XCUIElement.frame` struct evaluation and an app-level capture timing mismatch during dynamic rotation transitions, rather than an underlying native layout failure. Because the exact internal XCTest / UIKit KVC evaluation was not instrumented, the precise internal mechanism is treated as an observation mismatch. Historical task 1470 timeout results and clipped diagnostic images are preserved as factual evidence in companion review archives outside the repository.

### iPad Selection, Tabs Mode & Dismissal Rerun Evidence

- **Test Suite:** `testNativeNavigationAdaptiveSplitViewSelectionAndTabsMode` in `DesignOSAppleGalleryStoryUITests.swift`.
- **Target Device:** iPad Pro 11-inch (M5), iPadOS 26.2 Simulator (build 23C54).
- **Rerun Command:** `xcodebuild test -project Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj -scheme DesignOSAppleGallery-iOS -destination "platform=iOS Simulator,name=iPad Pro 11-inch (M5)" -only-testing:DesignOSAppleGalleryUITests/DesignOSAppleGalleryStoryUITests/testNativeNavigationAdaptiveSplitViewSelectionAndTabsMode -derivedDataPath <task-derived-data-ipad>`
- **Result:** `** TEST SUCCEEDED **` in 24.12s.
- **Platform Adaptation:** The tab verification was updated to support both iPhone bottom tab bar (`app.tabBars.buttons["Search"]`) and iPad top navigation bar adaptation (`app.buttons["Search"]`), verifying mode switching, item selection, and dismissal on iPad.

### iPhone 17 Pro Full StoryUITests Suite

- **Target Device:** iPhone 17 Pro, iOS 26.2 Simulator (build 23C54).
- **Run Command:** `xcodebuild test -project Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj -scheme DesignOSAppleGallery-iOS -destination "platform=iOS Simulator,name=iPhone 17 Pro" -only-testing:DesignOSAppleGalleryUITests/DesignOSAppleGalleryStoryUITests -derivedDataPath <task-derived-data>`
- **Result:** `** TEST SUCCEEDED **` — all 10 UI tests passed cleanly in 120.55s.

---

## 6. Baseline Gate Verification & Compiler Diagnostics

Deterministic gate verification on `audit/iphone-duo-os27` base commit `31e49d2`:
1. `swift test`: **PASSED** (90 tests in 0.25s).
2. `verify-documentation.sh`: **PASSED** (DocC build and markdown link checks clean).
3. `verify-catalog-bundle.sh`: **PASSED** (Bundle matches compiled typed authority).
4. `verify-consumer-quickstart.sh`: **PASSED** (Snippet compiles cleanly).
5. `verify-publication-boundary.sh --candidate`: **PASSED** (Classified release files clean, 413 classified files, 0 findings, 0 unapproved binary assets).
6. `test-publication-boundary.sh`: **PASSED** (Hostile probe tests pass).
7. `swift format lint --recursive Sources Tests`: **PASSED** (Code style clean).
8. `swift build -c release -Xswiftc -strict-concurrency=complete -Xswiftc -warnings-as-errors`:
   - **Historical Baseline Toolchain Crash:** Initial release compilation on baseline commit `31e49d2` under Swift 6.2.3 encountered a fatal `CopyPropagation` SIL compiler crash in `DesignOSStoryDescriptor.init(from:)` under `-O`.
   - **Workaround & Release Resolution:** A minimal, source-preserving memberwise initialization in `DesignOSStoryDescriptor.swift` avoids the observed `CopyPropagation` compiler crash during property evaluation (the underlying compiler-internal mechanism remains unproven). Optimization (`-O`) and strict concurrency flags remain fully enabled.
   - **Verified Progression:** The unchanged strict release build compiles cleanly. Package tests in debug configuration pass 91 tests (historical 90 plus 1 targeted descriptor decoding regression suite covering validation precedence and compatibility bounds), and the targeted decoder regression was executed and passed release optimization.
