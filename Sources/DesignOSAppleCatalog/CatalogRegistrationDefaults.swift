enum CatalogRegistrationDefaults {
  static let allPlatforms = DesignOSPlatform.allCases
  static let packageFloor = [
    DesignOSMinimumAvailability(platform: .iOS, majorVersion: 17),
    DesignOSMinimumAvailability(platform: .iPadOS, majorVersion: 17),
    DesignOSMinimumAvailability(platform: .macOS, majorVersion: 14),
  ]
  static let verificationCommand =
    "swift test && swift build -c release -Xswiftc -strict-concurrency=complete -Xswiftc -warnings-as-errors"

  static func runtime(
    id: RuntimeDeliverableID,
    symbol: String,
    fallback: String,
    axes: [DesignOSCustomizationAxis] = [],
    documentationPath: String,
    examplePath: String,
    storyID: DesignOSStoryID,
    platforms: [DesignOSPlatform] = allPlatforms,
    availability: [DesignOSMinimumAvailability] = packageFloor,
    module: String = "DesignOSApple",
    stateOwner: DesignOSContractOwner = .caller,
    accessibilityOwner: DesignOSContractOwner = .nativePlatform
  ) -> RuntimeDeliverableDescriptor {
    RuntimeDeliverableDescriptor(
      id: id,
      module: module,
      symbolOrNativeAPI: symbol,
      platforms: platforms,
      minimumAvailability: availability,
      fallback: fallback,
      customizationAxes: axes,
      stateOwner: stateOwner,
      accessibilityOwner: accessibilityOwner,
      documentationPath: documentationPath,
      examplePath: examplePath,
      storyDisposition: .executable(storyID),
      verificationCommand: verificationCommand
    )
  }
}
