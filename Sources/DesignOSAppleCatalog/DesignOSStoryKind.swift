/// The teaching category of an executable Gallery story.
public enum DesignOSStoryKind: String, Codable, CaseIterable, Hashable, Sendable {
  /// A runtime foundation such as semantic color or typography roles.
  case foundation
  /// A reusable semantic runtime component.
  case semanticComponent
  /// A package-internal composition primitive.
  case primitive
  /// A direct native API recipe.
  case nativeRecipe
  /// An extension-hosted recipe.
  case extensionRecipe
  /// An app-owned example that demonstrates runtime deliverables.
  case productDemo
}
