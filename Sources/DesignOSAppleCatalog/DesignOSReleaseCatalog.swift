/// The complete typed story authority for the Gallery and generated release bundle.
public enum DesignOSReleaseCatalog {
  /// Every executable Gallery story in stable identity order.
  public static let stories: [DesignOSStoryDescriptor] = {
    let values =
      FoundationStoryRegistrations.values
      + ComponentAndPrimitiveStoryRegistrations.values
      + NativeRecipeStoryRegistrations.values
      + ExtensionAndDogfoodStoryRegistrations.extensionValues
      + ExtensionAndDogfoodStoryRegistrations.dogfoodValues
    precondition(values.map(\.id) == DesignOSStoryID.allCases)
    precondition(Set(values.map(\.id)).count == values.count)
    return values
  }()
}
