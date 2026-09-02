import DesignOSApple

/// Catalog-owned registration failures for stable profile identifiers.
public enum DesignOSProfileRegistryError: Error, Equatable, Sendable {
  case invalidIdentifier
  case duplicateIdentifier
  case unknownProfile
}

/// Immutable catalog registration for a profile identifier and runtime value.
public struct DesignOSProfileRegistration: Equatable, Hashable, Sendable {
  /// The bounded catalog profile identifier.
  public let id: String
  /// The resolved runtime profile.
  public let profile: DesignOSProfile

  /// Creates a registration value; the registry validates its identifier.
  public init(id: String, profile: DesignOSProfile) {
    self.id = id
    self.profile = profile
  }
}

/// Immutable lookup table owned by the pilot catalog boundary.
public struct DesignOSProfileRegistry: Equatable, Sendable {
  private let registrations: [DesignOSProfileRegistration]

  /// Validates profile identifier syntax and uniqueness.
  public init(registrations: [DesignOSProfileRegistration]) throws {
    guard registrations.allSatisfy({ Self.isValidIdentifier($0.id) }) else {
      throw DesignOSProfileRegistryError.invalidIdentifier
    }
    let identifiers = registrations.map(\.id)
    guard Set(identifiers).count == identifiers.count else {
      throw DesignOSProfileRegistryError.duplicateIdentifier
    }
    self.registrations = registrations
  }

  /// Resolves a registered profile identifier.
  public func profile(for identifier: String) throws -> DesignOSProfile {
    guard let registration = registrations.first(where: { $0.id == identifier }) else {
      throw DesignOSProfileRegistryError.unknownProfile
    }
    return registration.profile
  }

  internal var identifiers: [String] { registrations.map(\.id) }

  static func isValidIdentifier(_ value: String) -> Bool {
    guard (1...32).contains(value.utf8.count), let first = value.utf8.first,
      first >= 97, first <= 122
    else { return false }
    return value.utf8.dropFirst().allSatisfy { byte in
      (byte >= 97 && byte <= 122) || (byte >= 48 && byte <= 57) || byte == 45
    }
  }
}

/// The story-admission and profile authority for the owner-approved five-story dogfood pilot.
public enum DesignOSPilotCatalog {
  private static let profileRegistry: DesignOSProfileRegistry = {
    do {
      let omniactProfile = try DesignOSProfile(
        fontDesign: .expressive,
        titleSubtitleSpacing: 2,
        sidebarContentSpacing: 8,
        listRowContentSpacing: 10
      )
      return try DesignOSProfileRegistry(
        registrations: [
          .init(id: "default", profile: .default),
          .init(id: "omniact", profile: omniactProfile),
        ]
      )
    } catch {
      preconditionFailure("The pilot catalog profile registry must remain valid.")
    }
  }()

  /// The current five dogfood stories in stable identity order.
  public static let admittedStories: [DesignOSStoryDescriptor] = {
    let values = ExtensionAndDogfoodStoryRegistrations.dogfoodValues
    precondition(Set(values.map(\.id)).count == values.count)
    return values
  }()

  /// Resolves a profile registered by this catalog.
  public static func profile(for identifier: String) throws -> DesignOSProfile {
    try profileRegistry.profile(for: identifier)
  }

  internal static var registeredProfileIdentifiers: [String] { profileRegistry.identifiers }
}
