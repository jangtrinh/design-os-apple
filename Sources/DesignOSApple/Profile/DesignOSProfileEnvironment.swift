import SwiftUI

private struct DesignOSProfileKey: EnvironmentKey {
  static let defaultValue = DesignOSProfile.default
}

extension EnvironmentValues {
  /// The immutable DESIGN:OS profile for this view subtree.
  public var designOSProfile: DesignOSProfile {
    get { self[DesignOSProfileKey.self] }
    set { self[DesignOSProfileKey.self] = newValue }
  }
}

extension View {
  /// Injects an immutable DESIGN:OS profile into this view subtree.
  public func designOSProfile(_ profile: DesignOSProfile) -> some View {
    environment(\.designOSProfile, profile)
  }
}
