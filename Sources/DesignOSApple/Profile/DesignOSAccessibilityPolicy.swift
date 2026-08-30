/// A fail-closed accessibility policy for package-owned rendering decisions.
public struct DesignOSAccessibilityPolicy: Hashable, Sendable {
  /// Package behavior for optional translucent custom surfaces.
  public enum Translucency: String, CaseIterable, Hashable, Sendable {
    /// Follow system accessibility preferences.
    case systemAdaptive
    /// Render package-owned optional translucency as opaque in every environment.
    case opaqueOnly
  }

  /// The package constraint applied after system accessibility preferences.
  public let translucency: Translucency

  /// Creates a policy that may constrain but never override system preferences.
  public init(translucency: Translucency) {
    self.translucency = translucency
  }

  /// Follows system accessibility preferences.
  public static let systemAdaptive = Self(translucency: .systemAdaptive)
  /// Disables optional translucency owned by this package.
  public static let opaqueOnly = Self(translucency: .opaqueOnly)
}
