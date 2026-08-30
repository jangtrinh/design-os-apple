/// Metadata for direct native empty-state call sites.
///
/// Call `ContentUnavailableView` directly at the iOS/iPadOS 17 and macOS 14
/// package floors. The caller supplies product-specific title, description,
/// image, and actions while SwiftUI owns adaptive layout, scaling, and semantic
/// grouping. Do not recreate the container with a custom stack or guessed asset.
public enum NativeContentUnavailableViewRecipe {}
