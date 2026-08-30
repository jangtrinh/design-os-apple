/// Metadata anchor for client-owned native presentation and sharing call sites.
///
/// Use `alert`, `confirmationDialog`, `sheet`, `popover`, and `ShareLink` directly on a
/// stable semantic owner. Use `fullScreenCover` only on iOS and iPadOS, where SwiftUI
/// exposes it. The caller owns independent presentation bindings and content; the system
/// owns dimming, sheet and popover chrome, anchors, safe areas, and focus. Native titles,
/// action roles, and labels provide accessibility meaning at the package floors.
public enum NativePresentationAndShareRecipe {}
