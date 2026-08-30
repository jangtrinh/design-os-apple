/// Metadata anchor for client-owned native menu, context-menu, and row-edit actions.
///
/// Use `Menu`, `contextMenu`, and `swipeActions` directly on the semantic content or row.
/// The caller owns action effects while Apple presentation and container APIs own menu
/// chrome, gesture handling, focus, pointer behavior, and row spacing. Native button
/// labels and roles provide accessibility meaning without a custom overlay or selection
/// menu. These APIs are available at the iOS 17, iPadOS 17, and macOS 14 package floors.
public enum NativeMenuContextAndEditActionsRecipe {}
