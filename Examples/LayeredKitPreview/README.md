# Layered Kit Preview

A separate, native SwiftUI consumer of `DesignOSApple`. It imports neither CalorieCam nor its
Core module. The only shared fixture is the admitted original synthetic `DemoMeal.png`; provenance
is recorded in `../CalorieCam/Resources/provenance.md`. No Luma artwork, logos, external images,
network requests, secrets, payment operations or permission prompts are used.

## Run on Apple platforms

With Xcode and XcodeGen installed:

```sh
cd Examples/LayeredKitPreview
xcodegen generate
xcodebuild -project LayeredKitPreview.xcodeproj -scheme LayeredKitPreview-macOS \
  -destination 'platform=macOS' -resultBundlePath /tmp/LayeredKitPreview-macOS.xcresult test
xcodebuild -project LayeredKitPreview.xcodeproj -scheme LayeredKitPreview-iOS \
  -destination 'platform=iOS Simulator,name=<installed iPhone or iPad simulator>' \
  -resultBundlePath /tmp/LayeredKitPreview-iOS.xcresult test
```

The project supports iOS/iPadOS 17 and macOS 14. CI can route directly to these schemes;
workflow integration is maintained separately from this example. Select a simulator installed by the runner.
Use a unique result-bundle path for each invocation. Tests attach original native screenshots
with `keepAlways`; extract these from the actual `.xcresult`. Source construction is not a
render or visual acceptance receipt.

## Gallery and fixture controls

Navigation groups foundations, composites, shells and all **18 atlas screen families**.
Each family now composes its actual shared API. This source availability is distinct from
compiled, rendered and visually accepted coverage.

The host consumes all 18 actual shared screen types, including browsing, editing, conversation,
selection, status and integration-boundary compositions. Composites use shared identity and field groups plus the nine later media headers, choice/selection,
category rail, message/composer, record and utility compositions;
shell selection instantiates eight actual content shells; the root uses the ninth adaptive
navigation shell.
The host never reimplements their scrolling/container policy.

Preview options provide a root-owned System/Light/Dark choice, populated/empty/error/busy fixture
states, accessibility text size, right-to-left layout and no-media mode. They are real native
controls. Appearance is never forced by a screen. Accessibility system policies are inherited,
not disabled to produce a prettier screenshot. Fixture state is local and resets with the process.

`LAYERED_KIT_SPECIMEN=<family-id>` is a documented specimen deep link for reproducible launches,
for example `media-composer`. It selects only a gallery destination, not an app business state.
UI tests choose appearance through the same visible controls as a person, inspect actual native
fields, images and family-specific content, and attach all 18 screen-type light/dark, keyboard,
selection, native alert, state and large-text captures. Utility uses a real local photo-zoom canvas.
Provider host offers the actual native ShareLink boundary; this does not verify an external payment
or authentication provider. No share destination is selected by the tests.

## Evidence boundary

This host is a representative native specimen route, not 393 completed reference states. The
per-reference mappings remain in `docs/luma-kit-coverage.json`. All state variants,
platform/window adaptation, RTL, VoiceOver, contrast and independent visual comparison require
separate receipts. Linux source checks cannot establish Xcode build, native screenshots or
assistive-technology behavior. The initial 33-API host compiled and executed in native run `38073632154`; its UI suite
failed on toolbar placement, inherited accessibility identifiers and platform picker queries.
Those failures informed the current repairs. The expanded 42-API revision awaits a native rerun;
source review is not a pass receipt.


## Composite and native-recipe coverage

The relevant screen fixtures instantiate all 11 composite APIs (the first two plus nine added
compositions), rather than listing names in a gallery. Native tests inspect the actual content
and controls of the added groups, exercise category selection and clearing native List selection,
and retain incoming/outgoing local-message metadata. No message is delivered externally.

Four native reuse recipes remain concrete compositions: the host supplies native `Section` inside
the grouped Form; `DesignOSFlatCollectionScreen` owns the native List's `Section` and receives the
host's `ForEach`/media rows (no nested Section); existing `DesignOSStatusMessage` supplies inline
status; and native `Text`/destructive `Button` fill the existing confirmation screen. These do not
add duplicate package wrappers. The photo canvas and ShareLink remain explicit native boundaries.

Source composition now references 42 layered APIs: 18 screen types, nine shells, four semantic
components and 11 composites. This is a source-use count, not a claim that all reference states
have passed native execution or visual comparison. The expanded suite has eight UI test methods, including native compact Back/options reachability.
