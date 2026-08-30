/// Immutable semantic color intent consumed by package-owned content.
public struct DesignOSSemanticColorProfile: Hashable, Sendable {
  /// The semantic color role for supporting text inside custom content.
  public let secondaryContent: DesignOSColorRole

  /// Creates a color profile from an adaptive semantic role.
  public init(secondaryContent: DesignOSColorRole) {
    self.secondaryContent = secondaryContent
  }
}
