enum NativeRecipeDeliverableRegistrations {
  static let values =
    NativeRecipeDeliverableRegistrationsA.values
    + NativeRecipeDeliverableRegistrationsB.values
}

enum NativeRecipeDeliverableRegistrationsA {
  static let values: [RuntimeDeliverableDescriptor] = [
    recipe(
      .buttonAndToolbarActions,
      "NativeButtonAndToolbarActionRecipe",
      "Button and ToolbarItem remain direct calls.",
      "NativeButtonAndToolbarActionRecipe.md",
      "NativeButtonAndToolbarActionRecipeGallery.swift",
      .buttonAndToolbarActions
    ),
    recipe(
      .contentUnavailable,
      "NativeContentUnavailableViewRecipe",
      "ContentUnavailableView remains the native empty-state fallback.",
      "NativeContentUnavailableViewRecipe.md",
      "NativeContentUnavailableViewRecipeGallery.swift",
      .contentUnavailable
    ),
    recipe(
      .elevatedBackground,
      "NativeElevatedBackgroundRecipe",
      "Use a dynamic semantic background in the real container.",
      "Native-Elevated-Background.md",
      "NativeElevatedBackgroundRecipeGallery.swift",
      .elevatedBackground
    ),
    recipe(
      .hierarchicalStyle,
      "NativeHierarchicalStyleRecipe",
      "Use native primary through quaternary foreground styles.",
      "Native-Hierarchical-Style.md",
      "NativeHierarchicalStyleRecipeGallery.swift",
      .hierarchicalStyle
    ),
    recipe(
      .homeScreenQuickActions,
      "NativeHomeScreenQuickActionRecipe / UIApplicationShortcutItem",
      "Omit the shortcut on unsupported hosts.",
      "NativeHomeScreenQuickActionRecipe.md",
      "NativeHomeScreenQuickActionRecipeGallery.swift",
      .homeScreenQuickActions,
      platforms: [.iOS, .iPadOS],
      availability: [
        .init(platform: .iOS, majorVersion: 17),
        .init(platform: .iPadOS, majorVersion: 17),
      ]
    ),
    recipe(
      .listSidebarAndDisclosure,
      "NativeListSidebarAndDisclosureRecipe",
      "List and NavigationSplitView own adaptive container behavior.",
      "NativeListSidebarAndDisclosureRecipe.md",
      "NativeListSidebarAndDisclosureRecipeGallery.swift",
      .listSidebarAndDisclosure
    ),
    recipe(
      .materialAndGlassSurface,
      "NativeMaterialAndGlassSurfaceRecipe",
      "Use native material or an opaque semantic background before glass availability.",
      "NativeMaterialAndGlassSurfaceRecipe.md",
      "NativeMaterialAndGlassSurfaceRecipeGallery.swift",
      .materialAndGlassSurface,
      axes: [.surface, .accessibility]
    ),
  ]

  private static func recipe(
    _ id: RuntimeDeliverableID,
    _ symbol: String,
    _ fallback: String,
    _ documentation: String,
    _ example: String,
    _ storyID: DesignOSStoryID,
    axes: [DesignOSCustomizationAxis] = [],
    platforms: [DesignOSPlatform] = CatalogRegistrationDefaults.allPlatforms,
    availability: [DesignOSMinimumAvailability] = CatalogRegistrationDefaults.packageFloor
  ) -> RuntimeDeliverableDescriptor {
    CatalogRegistrationDefaults.runtime(
      id: id,
      symbol: symbol,
      fallback: fallback,
      axes: axes,
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/\(documentation)",
      examplePath: "Examples/DesignOSAppleGallery/\(example)",
      storyID: storyID,
      platforms: platforms,
      availability: availability
    )
  }
}
