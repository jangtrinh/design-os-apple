/// Metadata for direct native hierarchical foreground styles.
///
/// Client call sites apply SwiftUI primary through quaternary foreground styles
/// to semantic content at iOS/iPadOS 17 and macOS 14. The native platform
/// resolves appearance and contrast; hierarchy never supplies an accessibility
/// name, value, or color-only meaning.
public enum NativeHierarchicalStyleRecipe {}
