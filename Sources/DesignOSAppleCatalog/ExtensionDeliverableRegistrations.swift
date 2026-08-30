enum ExtensionDeliverableRegistrations {
  static let values: [RuntimeDeliverableDescriptor] = [
    extensionRecipe(
      id: .extensionWidget,
      symbol: "ExtensionWidgetRecipe / WidgetKit.Widget",
      minimumVersion: 17,
      documentation: "ExtensionWidgetRecipe.md",
      example: "ExtensionWidgetGallery.swift",
      storyID: .extensionWidget
    ),
    extensionRecipe(
      id: .extensionControlWidget,
      symbol: "ExtensionControlWidgetRecipe / WidgetKit.ControlWidget",
      minimumVersion: 18,
      documentation: "ExtensionControlWidgetRecipe.md",
      example: "ExtensionControlWidgetGallery.swift",
      storyID: .extensionControlWidget
    ),
  ]

  private static func extensionRecipe(
    id: RuntimeDeliverableID,
    symbol: String,
    minimumVersion: Int,
    documentation: String,
    example: String,
    storyID: DesignOSStoryID
  ) -> RuntimeDeliverableDescriptor {
    CatalogRegistrationDefaults.runtime(
      id: id,
      symbol: symbol,
      fallback: "Omit this extension capability on unsupported platforms.",
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/\(documentation)",
      examplePath: "Examples/DesignOSAppleGallery/Extensions/\(example)",
      storyID: storyID,
      platforms: [.iOS, .iPadOS],
      availability: [
        .init(platform: .iOS, majorVersion: minimumVersion),
        .init(platform: .iPadOS, majorVersion: minimumVersion),
      ],
      module: "DesignOSAppleExtensions",
      stateOwner: .extensionHost
    )
  }
}
