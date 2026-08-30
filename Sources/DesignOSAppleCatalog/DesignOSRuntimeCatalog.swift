/// Stable lookup failures for runtime deliverable identities.
public enum DesignOSRuntimeCatalogError: Error, Equatable, Sendable {
  case unknownDeliverable
}

/// The sole typed registration authority for compiled runtime deliverables.
public enum DesignOSRuntimeCatalog {
  /// Complete release-candidate deliverables in stable identity order.
  public static let deliverables: [RuntimeDeliverableDescriptor] = {
    let values =
      FoundationDeliverableRegistrations.values
      + ComponentAndPrimitiveDeliverableRegistrations.values
      + NativeRecipeDeliverableRegistrations.values
      + ExtensionDeliverableRegistrations.values
    precondition(values.map(\.id) == RuntimeDeliverableID.allCases)
    precondition(Set(values.map(\.id)).count == values.count)
    return values
  }()

  /// Resolves a registered deliverable without guessing or fallback matching.
  public static func deliverable(
    for id: RuntimeDeliverableID
  ) throws -> RuntimeDeliverableDescriptor {
    guard let deliverable = deliverables.first(where: { $0.id == id }) else {
      throw DesignOSRuntimeCatalogError.unknownDeliverable
    }
    return deliverable
  }
}
