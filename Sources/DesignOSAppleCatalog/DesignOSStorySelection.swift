import DesignOSApple

/// An admitted story descriptor paired with its resolved subtree profile.
public struct DesignOSStorySelection: Equatable, Hashable, Sendable {
  /// The descriptor admitted by the pilot catalog.
  public let descriptor: DesignOSStoryDescriptor
  /// The profile resolved once by the catalog selector.
  public let profile: DesignOSProfile

  /// Creates a typed selection from an admitted descriptor and resolved profile.
  public init(descriptor: DesignOSStoryDescriptor, profile: DesignOSProfile) {
    self.descriptor = descriptor
    self.profile = profile
  }
}
