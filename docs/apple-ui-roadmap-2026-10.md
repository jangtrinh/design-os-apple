# Apple UI roadmap: October 2026

Verified against official Apple sources on **2026-10-10**. This is a bounded, implementation-oriented intake for native iOS/iPadOS/macOS UI and iPhone Duo. It is **not** an exhaustive SDK symbol diff or a claim that every new component is covered. Historical UKMC documents, indexes, and corpus are unchanged.

## Release and evidence boundaries

- Latest stable releases listed by Apple: iOS/iPadOS **27.0.1** (24A446), macOS **27.0.1** (26A434), Xcode **27** (27A266a).
- Prerelease tracks: Xcode **27.1 RC** (27A9275), Xcode **27.2 beta 2**; iOS/iPadOS/macOS **27.2 beta 3**.
- iPhone Duo is officially announced, with preorders October 16 and availability October 23. Apple says it ships with iOS 27.1. It is not shipping on this verification date.
- Use the SDK actually installed for implementation. Newest Duo symbols below remain **DOCUMENTED** until their SDK availability and compilation are established; do not assume they are supported on every platform at the same version.

Sources: [Apple release index](https://developer.apple.com/news/releases/), [iPhone Duo](https://www.apple.com/iphone-duo/), [announcement](https://www.apple.com/newsroom/2026/09/apple-unveils-iphone-duo/).

## Retrieval-ready status contract

Each recipe should carry `family`, `platforms`, `sdk_availability`, `source_url`, `verified_at`, `status`, `fallback`, and `verification_evidence`.

| Status | Required evidence |
| --- | --- |
| DOCUMENTED | Official source establishes the API or pattern; no execution claim. |
| IMPLEMENTED | Concrete repository implementation exists, with file/symbol references. |
| COMPILED | Implementation built successfully with a named Xcode/SDK, target, and command or build log. |
| DEVICE_VERIFIED | Named physical device and OS exercised the recorded scenarios; simulator checks are recorded separately. |

These are distinct evidence levels. A documentation link, code snippet, visual mockup, or successful test of another recipe does not establish compilation or device verification. Every family in this intake starts at **DOCUMENTED**; downstream implementations can attach their own evidence.

## Bounded coverage families

### 1. Adaptive navigation and persistent task state

**Retrieve:** `adaptive-shell`, `NavigationSplitView`, `TabView`, `size-class`, `state-continuity`.

Use standard navigation and available-space measurements. Duo outer portrait is compact horizontal/regular vertical; outer landscape is compact both; inner display is regular both. Avoid device idiom, fixed display dimensions, and orientation-based layout decisions. Building with iOS 27.1 SDK enables full-screen Duo treatment and vertically arranged standard bars.

**Calorie-photo application:** retain the imported photo, analysis, edited portions, and navigation selection in shared state while moving between a single flow and photo/review columns. Keep all functionality available in compact layouts.

**Checks:** resize, rotate, open/close, Split View on either side; foreground controls inside independent safe-area insets; background imagery may extend beyond them. Resolve screen-dependent values from the scene, not `UIScreen.main`.

[Prepare your app for Duo](https://developer.apple.com/videos/play/tech-talks/111461/)

### 2. Primary/secondary arrangements — future Duo extension

**Retrieve:** `ArrangementView`, `arrangementViewStyle`, `split-arrangement`, `overlay-arrangement`.

Documented symbols include `.split`, `.overlay`, `.axes(_:)`, `splitArrangementLayoutRatio`, `splitArrangementLayoutSize`, `splitArrangementFixedLayoutSize`, `overlayArrangementEdge`, and environments `splitArrangementAxis` / `overlayArrangementZIndex`.

**Calorie-photo application:** optional photo/review arrangement after SDK proof. Use the existing supported split/stack baseline first. Keep model identity independent of layout-container identity.

**Checks:** constrained widths, both split axes, overlay-to-separated transition, focus and selection continuity. Current September API documentation includes prerelease notices.

[Layout API inventory](https://developer.apple.com/documentation/swiftui/layout-fundamentals), [Arrangement style](https://developer.apple.com/documentation/swiftui/view/arrangementviewstyle%28_%3A%29)

### 3. Reserved regions and restrained displacement — future Duo extension

**Retrieve:** `ReservedRegion`, `reservedRegions`, `occlusion`, `division`.

`GeometryProxy.reservedRegions(kind:options:layoutDirectionBehavior:)` exposes regions, including active state, frame, margins, and identifier. `.occlusion` covers obstructing hardware/system UI; `.division` covers the fold. UIKit's Swift type is `UIView.ReservedRegion`.

**Calorie-photo application:** keep confirmation controls and food annotation handles out of obstructed regions. Do not split important photo details across a fold when a supported layout can avoid it. Avoid relocating continuous scrolling review content unnecessarily.

**Checks:** active/inactive regions, coordinate conversion, asymmetric margins, camera activation. Prefer system containers before custom geometry.

[GeometryProxy](https://developer.apple.com/documentation/swiftui/geometryproxy?language=o_5), [UIKit regions](https://developer.apple.com/documentation/uikit/uiview/reservedregion?changes=_2), [Adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463/)

### 4. Native bars, priority, and overflow

**Retrieve:** `native-toolbar`, `ToolbarOverflowMenu`, `visibilityPriority`, `vertical-bar`.

Use navigation-container-managed bars with titled symbol actions. Documented additions include `axisBehavior`, `ToolbarItemAxisBehavior`, `toolbarVerticalEdge`, `toolbarCompressionBehavior`, `toolbarVerticalBehavior`, and `.topBarPinnedTrailing`. Duo-specific additions remain DOCUMENTED pending SDK proof.

**Calorie-photo application:** keep Add Photo, Analyze, and Confirm understandable and reachable; preserve less frequent actions in a system overflow menu. Existing supported toolbar APIs are the baseline.

**Checks:** keyboard/PiP competition, narrow vertical width, RTL, action ordering, reduced transparency. Hardware-aligned vertical bars do not simply mirror to the other physical side in RTL. Provide titles even when only symbols are visible.

[Duo bars](https://developer.apple.com/videos/play/tech-talks/111462/), [ToolbarContent](https://developer.apple.com/documentation/swiftui/toolbarcontent?changes=_3_5)

### 5. Toolbar minimization and search

**Retrieve:** `toolbarMinimizationBehavior`, `toolbar-restoration`, `search-toolbar`.

Current spelling is `toolbarMinimizationBehavior(_:for:)`, **not** the older WWDC snippet's `toolbarMinimizeBehavior`. Companion APIs customize restoration and safe-area adjustment. Navigation-bar minimization can also minimize integrated top tabs.

**Calorie-photo application:** consider only for lengthy review history; essential confirmation should remain discoverable.

**Checks:** scroll direction, restored controls, content offset/safe-area changes, search focus, keyboard, accessibility. Verify supported SDK/platform first.

[Current minimization API](https://developer.apple.com/documentation/swiftui/view/toolbarminimizationbehavior%28_%3Afor%3A%29)

### 6. Reordering and swipe actions beyond List

**Retrieve:** `reorderable`, `reorderContainer`, `swipeActionsContainer`.

OS 27 introduces reusable reordering across lists/stacks/grids and swipe actions outside List. Keep item identity stable, commit ordering differences to the data model, and coordinate swipe presentation through the container.

**Calorie-photo application:** optional food-item ordering/edit/delete after a working analysis flow. Provide accessible menu/button alternatives to gestures and protect destructive edits.

**Checks:** partial/full swipe, cancellation, empty/single-item collections, undo, VoiceOver actions, keyboard operation.

[SwiftUI overview](https://developer.apple.com/videos/play/wwdc2026/269/)

### 7. Selection, input styling, and modal semantics

**Retrieve:** `TabsPickerStyle`, `TextInputBorderShape`, `item-bound-dialog`, `selectable-text`.

`TabsPickerStyle` distinguishes navigation tabs from value selection and announces tabs to VoiceOver. `TextInputBorderShape` supports automatic/capsule/rounded rectangle; use the new bordered text field style where available. Item/error-bound alerts and confirmation dialogs support back deployment, while interactive system text selection is linked to the 27 SDK.

**Calorie-photo application:** food quantity editing needs persistent labels, validation, focus retention, and explicit units. Use navigation-tab semantics only for destinations, not portion-value selection.

**Checks:** Dynamic Type, validation, localization, selection gestures, input focus through resizing, cancelled dialogs.

[Tabs picker](https://developer.apple.com/documentation/swiftui/tabspickerstyle?language=ob_6), [Input borders](https://developer.apple.com/documentation/swiftui/textinputbordershape?changes=__1), [Release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes)

### 8. Rendering, lazy content, and state lifetime

**Retrieve:** `AsyncImage-cache`, `State-macro`, `ContentBuilder`, `lazy-state`.

OS 27 adds HTTP caching and configurable requests/sessions for `AsyncImage`. Xcode 27's `State` macro avoids repeated class initialization and back-deploys to iOS 17-aligned systems. Compiler features and runtime API availability must be tracked separately.

**Calorie-photo application:** keep analysis/edit state outside disposable rows; distinguish loading, success, error, and retry. Local imported photos do not require `AsyncImage`.

**Checks:** row unload/reload, cancelled work, stale analysis responses, large photos, resizing while scrolled. Do not postpone essential lazy-row setup until `onAppear`.

[SwiftUI overview](https://developer.apple.com/videos/play/wwdc2026/269/), [Lazy stacks](https://developer.apple.com/videos/play/wwdc2026/321/)

### 9. Optional hinge and camera accessory — future Duo extension

**Retrieve:** `onHingeChange`, `DeviceHingeContext`, `CameraCaptureAccessory`, `sceneAccessory`.

Hinge updates support effects/interactions; geometry and arrangement APIs should drive layout. Handle missing hinge and closed/partially-open/fully-open states. `CameraCaptureAccessory` can show supplementary outer-display content during an eligible camera session; the system controls availability and presentation.

**Calorie-photo application:** future camera framing guidance or optional capture preview. This is not required for photo import or calorie review, and must not be the only way to operate the app.

**Checks:** availability vs enablement vs actual presentation, camera lifecycle, permissions, foreground state, closing device, unsupported hardware; provide conventional controls and Reduce Motion behavior.

[Hinge/scenes talk](https://developer.apple.com/videos/play/tech-talks/111464/), [Camera accessory](https://developer.apple.com/documentation/swiftui/cameracaptureaccessory), [Accessory lifecycle](https://developer.apple.com/documentation/swiftui/view/sceneaccessory%28content%3A%29?changes=_1_6%2C_1_6&language=objc%2Cobjc)

### 10. iPad/Mac windows, documents, and accessibility

**Retrieve:** `appearsActive`, `document-architecture`, `multiwindow`, `accessibility-matrix`.

OS 27 adds/refines inactive iPad window treatment, document protocols, menu presentation, and app resizing. Document families include `Document`, `ReadableDocument`, `WritableDocument`, readers/writers and creation sources. These are optional, not prerequisites for a simple meal log. On Duo, new-window availability is dynamic and limited to the inner display; handle activation errors.

**Calorie-photo application:** respect inactive-window state, keyboard/pointer navigation, privacy of food photos, and readable review results. Do not add a document architecture merely because it is new.

**Checks:** VoiceOver labels/order, Dynamic Type, contrast, Reduce Transparency/Motion, RTL, keyboard/pointer, error states and unsupported-feature fallback. Record physical-device evidence separately from simulator and visual checks.

[SwiftUI overview](https://developer.apple.com/videos/play/wwdc2026/269/), [Accessibility HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility?changes=latest_maj_6_3&language=objc), [Duo HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)

## Next implementation checks

1. Inventory the installed Xcode, SDKs, deployment target, and supported platforms before selecting recipes.
2. Ship the calorie-photo vertical slice using supported native navigation, photo selection, stable model state, review/edit controls, and error handling.
3. Add source-backed metadata and concrete implementation references for each adopted family; do not mark the whole roadmap IMPLEMENTED.
4. Compile each adopted API against the named SDK and exercise the compact/expanded, accessibility, and lifecycle matrix.
5. Introduce Duo prerelease extensions only behind verified availability and a tested fallback. Require device evidence after hardware availability before DEVICE_VERIFIED.

Apple's [October developer newsletter](https://developer.apple.com/hello/october26/) confirms Duo Figma and Sketch design kits are available through Apple Design Resources. These are visual references, not proof that native code compiles or behaves correctly.

### Known evidence limits

Some indexed Apple pages retain beta labels and older transcript spellings after later revisions. Use symbol declarations in the installed SDK and current release notes to resolve conflicts. This intake does not establish per-symbol platform availability for all September additions, nor exhaustive macOS coverage. No implementation, build, simulator, or physical-device result is claimed by this document.
