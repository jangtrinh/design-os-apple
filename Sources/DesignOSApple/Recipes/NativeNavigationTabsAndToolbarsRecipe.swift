/// Metadata anchor for client-owned native navigation, tabs, and toolbar composition.
///
/// Use `NavigationStack`, `NavigationSplitView`, `TabView`, and `ToolbarItem` directly at
/// the client call site. The caller owns navigation paths, tab selection, and actions;
/// native containers own hierarchy, chrome, safe areas, scroll edges, focus, and compact
/// or wide adaptation. Visible tab and toolbar labels preserve native accessibility roles
/// and selection. These APIs predate the iOS 17, iPadOS 17, and macOS 14 package floors.
public enum NativeNavigationTabsAndToolbarsRecipe {}
