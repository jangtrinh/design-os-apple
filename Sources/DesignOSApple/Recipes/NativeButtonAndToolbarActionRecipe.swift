/// Metadata for direct native button and toolbar action call sites.
///
/// Client code owns actions and disabled state, while `Button` and
/// `ToolbarItem` own native activation, focus, layout, and chrome at the
/// iOS/iPadOS 17 and macOS 14 floor. Visible labels provide accessibility
/// names; symbol-only labels require an explicit accessible name.
public enum NativeButtonAndToolbarActionRecipe {}
