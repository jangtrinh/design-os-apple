/// Exact native API discovery over existing release-catalog recipes.
///
/// Unlike story keyword lookup, this index distinguishes individual native calls
/// inside a broad recipe. It does not admit new stories, alter the v2 bundle, or
/// promise that every Apple API is covered. Unknown APIs fail closed.
public enum DesignOSNativeCapabilityIndex {
  /// API coverage in stable registration order, derived from existing deliverables.
  public static let capabilities: [DesignOSNativeCapability] = {
    let values = NativeControlCapabilityRegistrations.values
      + NativePresentationCapabilityRegistrations.values
    let terms = values.flatMap(\.lookupTerms)
    precondition(Set(values.map(\.id)).count == values.count)
    precondition(Set(terms).count == terms.count)
    return values
  }()

  /// Resolves an API name, framework-qualified name, or exact alias.
  ///
  /// For example, `DatePicker`, `SwiftUI.DatePicker`, and `date picker` resolve
  /// to the same capability. Signatures, fuzzy queries, and unsupported future
  /// API names are not guessed. Check the returned coverage before using it.
  public static func resolve(_ term: String) throws -> DesignOSNativeCapability {
    let normalized = DesignOSStoryDiscovery.normalize(term)
    let matches = capabilities.filter { $0.lookupTerms.contains(normalized) }
    guard matches.count == 1 else {
      throw matches.isEmpty
        ? DesignOSStoryDiscoveryError.notFound : DesignOSStoryDiscoveryError.ambiguous
    }
    return matches[0]
  }
}
