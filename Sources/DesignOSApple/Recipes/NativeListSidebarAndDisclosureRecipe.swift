/// Metadata anchor for client-owned native list, sidebar, and disclosure composition.
///
/// Use `List(selection:)`, `NavigationSplitView`, and `DisclosureGroup(isExpanded:)`
/// directly at the client call site. The caller owns data and bindings while the native
/// containers own scrolling, row metrics, safe areas, selection, focus, and compact or
/// multi-column adaptation. Visible row and disclosure labels must preserve native
/// accessibility names, selection, and expanded-state announcements. These APIs are
/// available at the iOS 17, iPadOS 17, and macOS 14 package floors.
public enum NativeListSidebarAndDisclosureRecipe {}
