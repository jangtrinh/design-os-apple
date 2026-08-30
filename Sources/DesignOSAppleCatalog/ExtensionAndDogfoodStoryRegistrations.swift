enum ExtensionAndDogfoodStoryRegistrations {
  private static let dogfoodRoot = "Examples/DesignOSAppleGallery/App/Shared/Dogfood/Shared/"

  static let extensionValues: [DesignOSStoryDescriptor] = [
    CatalogStoryRegistration.canonical(
      id: .extensionWidget,
      title: "Widget extension recipe",
      summary: "Native WidgetKit integration owned by an extension host.",
      deliverableID: .extensionWidget
    ),
    CatalogStoryRegistration.canonical(
      id: .extensionControlWidget,
      title: "Control Widget extension recipe",
      summary: "Availability-gated native Control Widget integration.",
      deliverableID: .extensionControlWidget
    ),
  ]

  static let dogfoodValues: [DesignOSStoryDescriptor] = [
    dogfood(
      .omniactSettingsShell,
      "Settings shell",
      "Native macOS settings navigation, values, and actions.",
      .listSidebarAndDisclosure,
      "OmniActSettingsStory.swift"
    ),
    dogfood(
      .omniactCommandRow,
      "Command row",
      "Native command controls inside reusable list-row content.",
      .designOSListRow,
      "OmniActCommandRowStory.swift"
    ),
    dogfood(
      .omniactHUDAutocompleteMaterial,
      "HUD autocomplete",
      "Native material command composition with accessibility fallback.",
      .materialAndGlassSurface,
      "OmniActHUDAutocompleteMaterialStory.swift"
    ),
    dogfood(
      .tocchienDictionarySearch,
      "Dictionary search",
      "Synthetic Vietnamese entries with native local search.",
      .textSearchAndKeyboardInput,
      "TocChienDictionarySearchStory.swift"
    ),
    dogfood(
      .tocchienNavigationTabs,
      "Navigation tabs",
      "Native TabView selection with two local destinations.",
      .navigationTabsAndToolbars,
      "TocChienNavigationTabsStory.swift"
    ),
    dogfood(
      .tocchienChampionHeroNegativeControl,
      "Synthetic hero control",
      "App-specific synthetic fixture; runtime unavailable.",
      nil,
      "TocChienChampionHeroNegativeControlStory.swift"
    ),
  ]

  private static func dogfood(
    _ id: DesignOSStoryID,
    _ title: String,
    _ summary: String,
    _ deliverableID: RuntimeDeliverableID?,
    _ file: String
  ) -> DesignOSStoryDescriptor {
    CatalogStoryRegistration.dogfood(
      id: id,
      title: title,
      summary: summary,
      deliverableID: deliverableID,
      examplePath: dogfoodRoot + file
    )
  }
}
