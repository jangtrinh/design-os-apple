# Native component coverage and retrieval

Apple Design OS provides reusable semantic composition and direct-native examples. It does
not implement every Apple UI control. Native controls remain Apple APIs at the caller's
site; a recipe namespace is a documentation anchor, not a control wrapper.

## Retrieve an individual native API

Import `DesignOSAppleCatalog` and use the additive native API index:

```swift
let capability = try DesignOSNativeCapabilityIndex.resolve("DatePicker")
// Also accepts "SwiftUI.DatePicker" and "date picker".
let story = capability.story
let sourcePath = capability.evidencePath
let coverage = capability.coverage
let availability = capability.minimumAvailability
```

`DesignOSNativeCapabilityIndex.capabilities` enumerates the bounded inventory. Each result
references an existing typed runtime deliverable and canonical story. Documentation,
recipe fallback, state ownership, and accessibility ownership come from that deliverable;
API-specific availability narrows broad recipe metadata where needed. Availability means
support within the package floors, not the API's historical introduction date. It does not
prove that a consuming compiler has the necessary SDK.

Check `coverage` before using a result:

- `nativeSpecimen`: the referenced Gallery source contains the real native call.
- `compileFixture`: a test source contains the native call, but the Gallery does not
  demonstrate that API. This classification does not claim the tests ran on this checkout.
- `documentationOnly`: guidance exists, without a corresponding registered native specimen.
- `hostIntegrationRequired`: a native fixture exists, but running the capability requires
  an app or extension host that the explanatory Gallery view does not supply.

Lookup is exact after case, diacritic, width, and whitespace normalization. Framework-qualified
names and registered aliases work; signatures and fuzzy descriptions do not. Missing APIs
throw `DesignOSStoryDiscoveryError.notFound`. Retrieval does not instantiate a view, execute
an action, or promise support on the current device.

The existing `DesignOSReleaseCatalog.resolve(_:)` still resolves story IDs and story keywords.
Its behavior, the generated v2 bundle schema and bytes, and the frozen pilot catalog are
unchanged. This index is a typed source lookup aid, not a separately serialized release
inventory. No v2 regeneration is needed for these additive lookup records.

## Actual reusable implementation

The typed release catalog currently contains 27 deliverables and 32 Gallery stories:

- Five foundations: profile, semantic color roles, platform semantic colors, typography,
  and surfaces.
- Two content components: `DesignOSListRow` and `DesignOSSidebarRow`.
- Four primitives: `AccessorySlotLayout`, `SectionContentLayout`, `SidebarToolbarContent`,
  and `SymbolContent`.
- Fourteen native recipe namespaces and two extension recipe namespaces.
- Five additional app-owned product demos; these are not public package components.

The native and extension recipe namespaces are metadata enums. Executable examples use
Apple APIs directly. The empty design component JSON registries are not the runtime
inventory; use the typed catalogs.

## Indexed native APIs

Real Gallery call sites:

- Actions: Button, ToolbarItem, Menu, contextMenu
- Content and collections: ContentUnavailableView, List, DisclosureGroup
- Navigation: NavigationStack, NavigationSplitView, NavigationLink, TabView
- Selection: Picker, DatePicker, ColorPicker, Toggle
- Values: ProgressView, Slider, Stepper
- Input: TextField, searchable
- Presentation: alert, sheet, ShareLink
- Surfaces: glassEffect, availability-gated to iOS/iPadOS/macOS 26 with native material
  and reduced-transparency opaque fallbacks. Apple-toolchain execution is still pending.

Compile fixtures beyond the Gallery specimens:

- swipeActions, FocusState, scrollDismissesKeyboard
- confirmationDialog, popover, fullScreenCover

Documentation-only: inspector.

Host-required fixtures: UIApplicationShortcutItem, Widget, ControlWidget. The widget
recipes are currently scoped to iOS/iPadOS hosts; the index does not infer macOS coverage
from WidgetKit's broader platform capabilities. ControlWidget starts at iOS/iPadOS 18.

These are source-level classifications. A Gallery route can exist while showing only an
explanatory label. Native device behavior, accessibility, and latest-SDK compatibility
require separate execution on an appropriate Apple toolchain and host.

## Known gaps and latest-platform limits

SecureField, TextEditor, Table, Gauge, dedicated Grid/OutlineGroup recipes, MultiDatePicker,
and media/file-transfer recipes are not currently admitted by this index. An incidental
use inside an app-owned demo does not establish a canonical native recipe. An unknown
lookup must not silently map to a vaguely similar control.

The four OS 27/iPhone Duo knowledge documents are intake material, not adopted runtime API
coverage. The index deliberately does not resolve TabsPickerStyle, textInputBorderShape,
concentricCornerRadii, NSRefreshController, or a fictional device-specific control. The
existing adaptive-navigation example uses native NavigationSplitView, without inventing
Duo point dimensions or posture APIs. Consult the
[platform evolution policy](apple-platform-evolution.md) before adopting new SDK calls.

The next practical increments are richer native text input, data collections, complete
interactive presentation variants, Apple-host validation of the glass specimen, and macOS
scene/command examples. Add genuine call sites and focused tests before labeling new APIs
as specimens. Add package-owned components only where reusable semantic composition is
needed and Apple does not already own that control.

## Verify

On a supported Apple development host:

```bash
swift test --filter nativeCapability
scripts/verify-catalog-bundle.sh
```

Tests cover exact API/alias lookup, collisions, source references, existing-story
relationships, platform bounds, missing/future API rejection, and unchanged v2 projection.
They do not replace interactive, device, accessibility, or latest-SDK validation.
