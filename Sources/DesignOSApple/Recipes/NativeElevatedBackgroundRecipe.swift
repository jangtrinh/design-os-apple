/// Metadata for elevated contextual backgrounds in direct native call sites.
///
/// Use approved dynamic semantic background roles in their real list, form,
/// navigation, sheet, or window context. The project floor is iOS/iPadOS 17
/// and macOS 14; neither platform accepts literal colors or forced traits.
/// Backgrounds have no accessibility role, so descendants retain their labels,
/// roles, values, and system-resolved contrast.
public enum NativeElevatedBackgroundRecipe {}
