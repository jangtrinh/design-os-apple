/// Apple platforms supported by a cataloged deliverable.
public enum DesignOSPlatform: String, CaseIterable, Codable, Hashable, Sendable {
  case iOS
  case iPadOS
  case macOS
}

/// Minimum operating-system version for one supported platform.
public struct DesignOSMinimumAvailability: Codable, Equatable, Hashable, Sendable {
  /// The supported platform.
  public let platform: DesignOSPlatform
  /// The minimum major operating-system version.
  public let majorVersion: Int

  /// Creates an availability row.
  public init(platform: DesignOSPlatform, majorVersion: Int) {
    self.platform = platform
    self.majorVersion = majorVersion
  }
}

/// Design-language axes a runtime deliverable intentionally consumes.
public enum DesignOSCustomizationAxis: String, CaseIterable, Codable, Hashable, Sendable {
  case typography
  case spacing
  case radius
  case semanticColors
  case surface
  case accessibility
}

/// Closed ownership vocabulary for state and accessibility contracts.
public enum DesignOSContractOwner: String, Codable, Hashable, Sendable {
  case caller
  case runtime
  case nativePlatform
  case extensionHost
}

/// Canonical Gallery coverage for one runtime deliverable.
public struct DesignOSStoryDisposition: Codable, Equatable, Hashable, Sendable {
  /// The executable canonical story, or `nil` for a documented recipe without a Gallery route.
  public let storyID: DesignOSStoryID?
  /// Human-readable reason when no executable story exists.
  public let recipeOnlyReason: String?

  /// Creates an executable story disposition.
  public static func executable(_ storyID: DesignOSStoryID) -> Self {
    Self(storyID: storyID, recipeOnlyReason: nil)
  }

  /// Creates a documented recipe-only disposition.
  public static func recipeOnly(_ reason: String) -> Self {
    Self(storyID: nil, recipeOnlyReason: reason)
  }

  private init(storyID: DesignOSStoryID?, recipeOnlyReason: String?) {
    self.storyID = storyID
    self.recipeOnlyReason = recipeOnlyReason
  }
}

/// Immutable identity and integration contract for one runtime deliverable.
public struct RuntimeDeliverableDescriptor: Codable, Equatable, Hashable, Sendable {
  public let id: RuntimeDeliverableID
  public let module: String
  public let symbolOrNativeAPI: String
  public let platforms: [DesignOSPlatform]
  public let minimumAvailability: [DesignOSMinimumAvailability]
  public let fallback: String
  public let customizationAxes: [DesignOSCustomizationAxis]
  public let stateOwner: DesignOSContractOwner
  public let accessibilityOwner: DesignOSContractOwner
  public let documentationPath: String
  public let examplePath: String
  public let storyDisposition: DesignOSStoryDisposition
  public let verificationCommand: String

  /// Creates a complete typed catalog record.
  public init(
    id: RuntimeDeliverableID,
    module: String,
    symbolOrNativeAPI: String,
    platforms: [DesignOSPlatform],
    minimumAvailability: [DesignOSMinimumAvailability],
    fallback: String,
    customizationAxes: [DesignOSCustomizationAxis],
    stateOwner: DesignOSContractOwner,
    accessibilityOwner: DesignOSContractOwner,
    documentationPath: String,
    examplePath: String,
    storyDisposition: DesignOSStoryDisposition,
    verificationCommand: String
  ) {
    self.id = id
    self.module = module
    self.symbolOrNativeAPI = symbolOrNativeAPI
    self.platforms = platforms
    self.minimumAvailability = minimumAvailability
    self.fallback = fallback
    self.customizationAxes = customizationAxes
    self.stateOwner = stateOwner
    self.accessibilityOwner = accessibilityOwner
    self.documentationPath = documentationPath
    self.examplePath = examplePath
    self.storyDisposition = storyDisposition
    self.verificationCommand = verificationCommand
  }
}
