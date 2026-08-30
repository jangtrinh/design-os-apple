/// Metadata anchor for iOS and iPadOS 17-or-newer WidgetKit call sites.
///
/// Client extension hosts declare `Widget`, `WidgetBundle`, `StaticConfiguration`, and
/// their timeline provider and content directly. The host owns lifecycle, supported
/// families, data, and intent state; the system owns placement, bounds, margins, and
/// interaction chrome.
/// Use native labels and values, semantic colors, and native text styles so content
/// follows VoiceOver, contrast, and Dynamic Type settings. This library provides no
/// widget wrapper, lifecycle entry point, bundle metadata, entitlement, or visual clone.
@available(iOS 17.0, *)
@available(macOS, unavailable, message: "Widget recipes belong to an admitted iOS extension host.")
public enum ExtensionWidgetRecipe {}
