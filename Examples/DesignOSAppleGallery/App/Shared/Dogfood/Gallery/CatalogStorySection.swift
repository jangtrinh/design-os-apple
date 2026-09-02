import DesignOSAppleCatalog

enum CatalogStorySection: String, CaseIterable, Identifiable {
  case foundations = "Foundations"
  case components = "Components"
  case nativePatterns = "Native patterns"
  case extensionRecipes = "Extension recipes"
  case productStories = "Product stories"
  case implementationInternals = "Implementation internals"

  var id: Self { self }

  nonisolated static func section(for storyID: DesignOSStoryID) -> Self {
    let namespace = storyID.rawValue.split(separator: ".", maxSplits: 1).first
    switch namespace {
    case "foundation": return .foundations
    case "component": return .components
    case "primitive": return .implementationInternals
    case "native": return .nativePatterns
    case "extension": return .extensionRecipes
    default: return .productStories
    }
  }
}
