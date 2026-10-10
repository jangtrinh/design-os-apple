enum NativePresentationCapabilityRegistrations {
  static let values: [DesignOSNativeCapability] = [
    .init(nativeAPI: "alert", aliases: ["native alert"], deliverableID: .presentationAndShare),
    .init(nativeAPI: "sheet", aliases: ["native sheet"], deliverableID: .presentationAndShare),
    .init(nativeAPI: "ShareLink", aliases: ["share link"], deliverableID: .presentationAndShare),
    presentationFixture("confirmationDialog", aliases: ["confirmation dialog"]),
    presentationFixture("popover", aliases: ["native popover"]),
    .init(
      nativeAPI: "fullScreenCover", aliases: ["full screen cover"],
      deliverableID: .presentationAndShare, coverage: .compileFixture,
      evidencePath: presentationFixturePath,
      minimumAvailability: [
        .init(platform: .iOS, majorVersion: 17),
        .init(platform: .iPadOS, majorVersion: 17),
      ]
    ),
    .init(
      nativeAPI: "inspector", aliases: ["native inspector"], deliverableID: .presentationAndShare,
      coverage: .documentationOnly,
      evidencePath: "Sources/DesignOSApple/DesignOSApple.docc/NativePresentationAndShareRecipe.md"
    ),
    .init(
      nativeAPI: "glassEffect", aliases: ["glass effect"], deliverableID: .materialAndGlassSurface,
      minimumAvailability: [
        .init(platform: .iOS, majorVersion: 26),
        .init(platform: .iPadOS, majorVersion: 26),
        .init(platform: .macOS, majorVersion: 26),
      ]
    ),
    .init(
      nativeAPI: "UIApplicationShortcutItem", framework: "UIKit",
      aliases: ["home screen quick action"],
      deliverableID: .homeScreenQuickActions, coverage: .hostIntegrationRequired,
      evidencePath: "Tests/DesignOSAppleTests/NativeHomeScreenQuickActionRecipeTests.swift"
    ),
    .init(
      nativeAPI: "Widget", framework: "WidgetKit", aliases: ["native widget"],
      deliverableID: .extensionWidget, coverage: .hostIntegrationRequired,
      evidencePath: "Tests/DesignOSAppleTests/Extensions/ExtensionWidgetTests.swift"
    ),
    .init(
      nativeAPI: "ControlWidget", framework: "WidgetKit", aliases: ["control widget"],
      deliverableID: .extensionControlWidget, coverage: .hostIntegrationRequired,
      evidencePath: "Tests/DesignOSAppleTests/Extensions/ExtensionControlWidgetTests.swift"
    ),
  ]

  private static let presentationFixturePath =
    "Tests/DesignOSAppleTests/NativePresentationAndShareRecipeTests.swift"

  private static func presentationFixture(
    _ api: String, aliases: [String]
  ) -> DesignOSNativeCapability {
    .init(
      nativeAPI: api, aliases: aliases, deliverableID: .presentationAndShare,
      coverage: .compileFixture, evidencePath: presentationFixturePath
    )
  }
}
