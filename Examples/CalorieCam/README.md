# CalorieCam native dogfood app

A native SwiftUI food journal for iPhone, iPad and Mac, consuming DESIGN:OS Apple rather than reproducing a web screen. **By default this runs offline with a clearly labeled fixed-demo estimator.** A selected photo is a visual reference; “Try demo estimate” always returns the same labeled fixture and never analyzes or uploads it. Manual entry is functional. An optional configured backend enables an explicitly confirmed AI-estimation flow; live inference has not been tested here.

## Build on a Mac

Requirements: an Xcode toolchain supporting Swift 6.2 (the root package requirement), compatible simulator runtimes, and XcodeGen 2.45.4 or later. The deployment floors remain iOS/iPadOS 17 and macOS 14. Install XcodeGen from its official project or Homebrew if needed.

```sh
cd Examples/CalorieCam
xcodegen generate
open CalorieCam.xcodeproj
```

Choose `CalorieCam-iOS` for an iPhone/iPad simulator or signed device; choose `CalorieCam-macOS` for Mac. Set your own development team for device signing. The simulator does not have a camera: use Photos, Import image file, or manual entry. Camera permission is requested only after “Take photo.” PhotosPicker grants selection access without requesting unrestricted photo-library permission. Mac uses PhotosPicker or security-scoped file import, not a camera.

```sh
# Foundation domain/storage tests
swift test --package-path Core
# Select an installed simulator from: xcrun simctl list devices available
xcodebuild test -project CalorieCam.xcodeproj -scheme CalorieCam-iOS \
  -destination 'platform=iOS Simulator,id=YOUR_SIMULATOR_UDID'
xcodebuild test -project CalorieCam.xcodeproj -scheme CalorieCam-macOS \
  -destination 'platform=macOS'
```

## Try the flow

1. Add meal; take a photo, choose one, or import an image under 15 MB.
2. Choose “Try demo estimate” explicitly, or “Enter meal manually.” Demo provenance remains attached after editing.
3. Review and edit every food name, portion and calorie value. Add/remove foods, change date or add a note. Invalid values block saving.
4. Save to the selected day. The journal total is computed from that day’s saved items, including labeled demo meals. It is not a prescribed calorie goal.
5. Select a meal for details. Delete requires confirmation; leaving an unfinished review asks before discarding.

The native split view adapts to compact iPhone navigation, iPad windows and Mac. Shared entry/review state survives ordinary layout changes. Native List, ScrollView, TextField, DatePicker, toolbar and sheets own interaction and system appearance. The opt-in `DesignOSAppStyle.editorial` supplies the shared palette/metrics/profile. `DesignOSMediaRow`, `DesignOSAppSectionHeader`, `DesignOSAppSurface`, `DesignOSPrimaryButtonStyle` and `DesignOSMediaBackdrop` compose the content without replacing native controls. The flat journal and photo-led dark composer follow the inspected Luma reference; they do not copy Luma branding, artwork or unrelated tabs. A selected photo supplies the backdrop. Reduce Transparency or Increase Contrast uses an opaque fallback. No custom animation or undocumented device-posture API is used.

## Storage and privacy

The versioned JSON journal lives in the app’s Application Support/CalorieCam/journal.json (inside its sandbox where applicable). Only food names, portions, calorie values, dates, notes and provenance are saved. The app does not implement encryption, sync, export or telemetry. The optional backend is separate; see below. Normal platform backups may include the journal. Atomic writes update in-memory state only after success. A missing journal is empty; a corrupt, inaccessible or unsupported journal blocks new saves/deletes and preserves the existing file. Resolve file access or restore a valid backup, then use “Try opening again.” The app never silently resets it.

The UI-test environment variable CALORIECAM_TEST_JOURNAL selects a separate temporary journal. Production launches do not set it. These temporary test journals are intentionally not auto-deleted by app startup.

## Optional AI estimation

See `Server/` for the companion backend and its deployment/security limitations. Configure the complete HTTPS `/analyze` endpoint via the Xcode scheme environment variable `CALORIECAM_ANALYSIS_URL`, or add the same key to Info.plist. Example: `https://your-service.example/analyze` (replace with your actual service). No default endpoint is supplied. URL credentials, query strings and fragments are rejected. Release builds require HTTPS.

For **Debug builds on iOS Simulator or Mac only**, start the server as described in `Server/README.md`, then set scheme environment variables `CALORIECAM_ANALYSIS_URL=http://127.0.0.1:8787/analyze` (use the server’s configured port) and `CALORIECAM_ALLOW_LOCAL_HTTP=1`. Both are required. The opt-in only permits exact localhost / 127.0.0.1 / ::1; it never allows insecure remote hosts. The generated Info.plists permit ATS local networking only, not arbitrary Internet loads. Runtime configuration still blocks HTTP in Release. The Mac sandbox allows outgoing network connections for analysis.

A physical iPhone’s localhost is the phone, not your Mac. Physical-device testing needs a secured HTTPS service; do not point at a LAN HTTP address or weaken ATS globally.

When configured, “Estimate with AI” appears after photo selection. A confirmation names the configured host and OpenAI before any upload. The app downscales to a maximum 1,600-pixel edge and re-encodes JPEG without the original EXIF metadata; normalized bytes must fit the core 5 MiB limit. It sends only that JPEG, not the journal or notes. Results remain editable and labeled estimated; nothing is saved automatically. Errors permit retry or manual entry, and leaving cancels the request. There is no automatic retry or upload after choosing a photo.

The backend URL is public configuration, not a credential. Keep OpenAI keys server-side. Before distributing, add appropriate authentication/abuse protection, publish an accurate privacy/retention policy for the deployed service, and verify inference quality, upload consent, cancellation and real-device behavior. Do not imply visual calorie accuracy. No live endpoint/key was supplied in this build, so end-to-end AI inference is NOT VERIFIED.

## Verification status

This latest editorial styling revision is NOT VERIFIED on Apple tooling yet. Earlier revisions compiled and produced genuine XCTest screenshots, including a six-test macOS pass. Their iOS artifacts also identified keyboard-accessory overlap and platform row-accessibility differences now addressed in the pending source. Those older screenshots do not validate this visual revision. Use the latest native CI run and its xcresult artifacts for current build/test evidence. Local authoring remains on Linux without Swift, Xcode, XcodeGen or Simulator. No iPhone Duo-specific compile claim is made; that device’s extra capabilities require a supported SDK/device evidence pass.

Source review: explicit provenance, save validation, durable single-writer storage, no default photo upload, explicit optional upload confirmation, native controls, semantic colors, SF Symbols and Dynamic Type row adaptation. There are no custom animations, so no motion is introduced when Reduce Motion is on. HTML `ui gate` / slop-detect / browser screenshots do not validate native SwiftUI and were not used as substitutes.

Before release, run both build/test schemes plus VoiceOver, keyboard-only, large accessibility text, light/dark and Increase Contrast checks; capture compact iPhone, iPad narrow/wide and Mac resized windows. Test real-camera allow/deny/cancel, picker cancel, oversized/invalid imports, nonnumeric/negative calories, zero-food review, persistence across relaunch, failed/corrupt journal recovery, and delete cancel/confirm. Measure native hit areas and contrast in rendered builds. All these device/visual gates remain open.

## Native component ledger

| Interaction | Native owner / API | DESIGN:OS role |
| --- | --- | --- |
| Journal and meal detail navigation | `NavigationSplitView`, plain `List(selection:)`, `NavigationLink` | Editorial app style injected at root; no replacement navigation |
| Saved meal row | Native List row + `DesignOSMediaRow` composition | Editorial media spacing, semantic metadata and accessibility-size vertical reflow |
| Add/review workflow | `sheet`, `NavigationStack`, native `ScrollView` with `LabeledContent`/`TextField`/`DatePicker` groups | Editorial surfaces and selected-photo backdrop; native presentation/focus |
| Food/portion/calorie editing | Labeled `TextField`; decimal keyboard on iOS | Platform typography; explicit 44pt editor minimums |
| Save/cancel | Native toolbar confirmation/cancellation placements | SF Symbol labels for icon actions; standard keyboard default action |
| Date/time and daily scope | Native `DatePicker` | Platform-adaptive date control, no custom wheel |
| Photo selection | `PhotosPicker`, `fileImporter` | Native permission/selection UI |
| iPhone/iPad camera | `UIImagePickerController`, AVFoundation permission request | System capture UI; no custom shutter or device-posture behavior |
| Meal/food deletion and upload consent | `confirmationDialog` | Native destructive/cancel roles |
| Empty / loading / failed operations | `ContentUnavailableView`, `ProgressView`, inline Section, `alert` | Semantic secondary labels; no decorative dashboards |
| Local persistence | Foundation versioned JSON with atomic writes | Shared core state and validation; no rendering-layer duplication |

These native owners can adopt system chrome when built with a compatible current SDK; source inspection is not proof of current-OS, Duo, or physical-device behavior. No hinge/arrangement API has been invented or feature-gated on a guessed device name. Consult [Mobbin research](../../docs/caloriecam-mobbin-research.md) for the review-before-save and portion-entry references; visual copying is not the implementation strategy.

### Open accessibility and adaptation checks

- [ ] Dynamic Type: all accessibility sizes, long food names, multi-line portions, numeric fields and saved-row reflow without clipping
- [ ] RTL and localization: mirrored navigation, long labels, locale decimal separators/digits and date formatting; the numeric parser currently normalizes the locale decimal separator, not every localized digit system
- [ ] VoiceOver: photo reference label, food labels/units, saved meal provenance, destructive confirmation, validation errors and focus after dismiss
- [ ] Keyboard-only Mac/iPad: all controls, file picker, default Save action, modal focus and cancellation
- [ ] Reduce Motion: verify native transitions with setting enabled; app adds no custom animation
- [ ] Reduce Transparency / Increase Contrast: verify native surfaces and semantic labels in light and dark appearance
- [ ] Native hit areas: measure at least 44pt for touch actions, including toolbar controls supplied by the platform
- [ ] Window adaptation: compact iPhone, iPad narrow/wide multitasking and resizable Mac; selection and unsaved review state remain coherent

All checklist items are NOT VERIFIED until run on Apple tooling. The Linux evidence is limited to YAML/source checks and the separately documented backend/core checks.


### UI-test screenshot evidence

The cross-platform XCUI suite attaches actual `XCUIApplication.screenshot()` captures with `XCTAttachment.lifetime = .keepAlways` at these states:

- `01-empty-diary`
- `02-capture-photo-choices`
- `03-editable-meal-review`
- `04-saved-diary`
- `05-invalid-calorie-review`

The empty, capture, review and saved-state screenshots are attached only after the expected state is found. They are generated during an actual Apple test run, not at source-authoring time. Preserve the run’s `.xcresult` bundle in CI and inspect its Attachments in Xcode; this source change alone is not screenshot evidence or a visual-quality pass. A new portable regression types an out-of-range numeric value and verifies that Save is disabled. Empty/nonnumeric text, locale digit systems, camera, modal focus, full accessibility and the broader visual matrix still need their own runtime checks.


## Luma-reference adaptation and sample photo

The app now consumes the reusable editorial native kit described in [the source-backed reference analysis](../../docs/luma-style-reference.md): flat light/dark journal, compact navigation, media-led rows, monochrome actions and photo-derived dark capture/review atmosphere. Geometry is reconstructed from screenshots; 100% visual parity is not verified. Photo atmosphere belongs only to the selected image and is disabled when Reduce Transparency or Increase Contrast requires an opaque surface.

“Try sample meal” loads the bundled synthetic `Resources/DemoMeal.png`, then the existing offline fixed 430-kcal demo fixture. It never uploads or auto-saves. The image is a clearly labeled sample illustration, not evidence for the fixture’s nutritional accuracy. Native UI coverage includes `09-sample-photo-review`, generated only in an actual test run. Saved demo-origin rows may reuse that same labeled sample illustration; real user photos still are not persisted, and manual/remote records use an honest food symbol instead. No user-photo retention behavior or journal schema was added.


### Native visual correction pass

The sample uses one explicit Bundle URL/data decoder on both platforms, including saved thumbnails and detail covers; raw image-name lookup was blank in actual Mac and iPhone artifacts. Cover bounds now apply a continuous rounded shape to the visible square image, rather than a wider transparent frame. These covers are not inset inside another rounded container, so their radius is independent. True inset surfaces in the shared kit use its nested-radius geometry helper. The original selected bytes are unchanged.

Review and selected detail use native scrolling plus shared `.ambient` content groups around genuine platform controls. This avoids the opaque AppKit grouped-Form surface that masked the image backdrop. Manual/remote details retain a neutral fallback because their personal photos are not stored. The field rows use native FocusState and a 44-point tap target; the UI tests close each editing keyboard with its ordinary Done action before opening the next field. The focused calorie field also offers a visible Clear calories keyboard action; an empty value blocks saving until a valid number is entered. Saved rows expose a concise, explicit VoiceOver summary including meal time and stable test identity across phone, tablet and Mac. App-owned content actions use shared full-pill primary/secondary button styles; native toolbar and confirmation-dialog controls retain system presentation.

Debug builds print `CalorieCamRenderEnvironment` with photo-presence, appearance and accessibility-policy booleans only. These diagnostics record actual rendering conditions; they do not force transparency, change accessibility settings or log meal/photo content. `11-sample-detail` captures the actual decoded sample cover and privacy caption after selecting a saved demo row. The new visual pass still requires its own native CI screenshots and acceptance review.
