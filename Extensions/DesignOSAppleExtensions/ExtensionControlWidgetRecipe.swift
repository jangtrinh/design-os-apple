/// Metadata anchor for iOS and iPadOS 18-or-newer Control Widget call sites.
///
/// Client extension hosts declare `ControlWidget`, `StaticControlConfiguration`, and
/// `ControlWidgetButton` or `ControlWidgetToggle` directly with App Intents. The host
/// owns lifecycle, intent state, and supported controls; the system owns placement,
/// bounds, and interaction chrome. Native labels, values, intent descriptions, semantic
/// colors, and text styles preserve accessibility. This library provides no control
/// wrapper, lifecycle entry point, bundle metadata, entitlement, or visual clone.
@available(iOS 18.0, *)
@available(
  macOS,
  unavailable,
  message: "Control Widget recipes belong to an admitted iOS extension host."
)
public enum ExtensionControlWidgetRecipe {}
