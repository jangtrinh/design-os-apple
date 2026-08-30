/// Immutable construction intent for package-owned non-interactive surfaces.
public struct DesignOSSurfaceProfile: Hashable, Sendable {
  /// The semantic surface role resolved by the platform adapter.
  public let role: DesignOSSurfaceRole

  /// Creates a surface profile without taking ownership of native containers.
  public init(role: DesignOSSurfaceRole) {
    self.role = role
  }
}
