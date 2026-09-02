enum ExtensionAndDogfoodStoryRegistrations {
  private static let dogfoodRoot = "Examples/DesignOSAppleGallery/App/Shared/Dogfood/Shared/"

  static let extensionValues: [DesignOSStoryDescriptor] = [
    CatalogStoryRegistration.canonical(
      id: .extensionWidget,
      title: "Widget extension recipe",
      summary: "Native WidgetKit integration owned by an extension host.",
      kind: .extensionRecipe,
      primaryKeyword: "widget extension",
      aliases: ["widgetkit recipe"],
      intentQueries: ["build a widget extension"],
      relatedStoryIDs: [.extensionControlWidget, .homeScreenQuickActions],
      deliverableID: .extensionWidget
    ),
    CatalogStoryRegistration.canonical(
      id: .extensionControlWidget,
      title: "Control Widget extension recipe",
      summary: "Availability-gated native Control Widget integration.",
      kind: .extensionRecipe,
      primaryKeyword: "control widget",
      aliases: ["control center widget"],
      intentQueries: ["build a control widget"],
      relatedStoryIDs: [.extensionWidget, .homeScreenQuickActions],
      deliverableID: .extensionControlWidget
    ),
  ]

  static let dogfoodValues: [DesignOSStoryDescriptor] = [
    dogfood(
      .omniactSettingsShell,
      "Settings shell",
      "Native macOS settings navigation, values, and actions.",
      "settings shell",
      ["app settings"],
      ["build app settings"],
      [.listSidebarAndDisclosure, .sidebarRow],
      [.listSidebarAndDisclosure],
      "OmniActSettingsStory.swift"
    ),
    dogfood(
      .omniactCommandRow,
      "Command row",
      "Native command controls inside reusable list-row content.",
      "command row",
      ["command list row"],
      ["build a command row"],
      [.listRow, .buttonAndToolbarActions],
      [.designOSListRow],
      "OmniActCommandRowStory.swift"
    ),
    dogfood(
      .tocchienDictionarySearch,
      "Dictionary search",
      "Synthetic Vietnamese entries with native local search.",
      "dictionary search",
      ["word lookup"],
      ["build a dictionary search"],
      [.textSearchAndKeyboardInput, .contentUnavailable],
      [.textSearchAndKeyboardInput],
      "TocChienDictionarySearchStory.swift"
    ),
    dogfood(
      .tocchienNavigationTabs,
      "Navigation tabs",
      "Native TabView selection with two local destinations.",
      "navigation demo",
      ["app tabs"],
      ["build app tab navigation"],
      [.navigationTabsAndToolbars, .buttonAndToolbarActions],
      [.navigationTabsAndToolbars],
      "TocChienNavigationTabsStory.swift"
    ),
    dogfood(
      .tocchienChampionHeroNegativeControl,
      "Synthetic hero control",
      "App-specific synthetic fixture; runtime unavailable.",
      "hero control",
      ["synthetic hero"],
      ["show a synthetic hero fixture"],
      [.symbolContent, .elevatedBackground],
      [],
      "TocChienChampionHeroNegativeControlStory.swift"
    ),
  ]

  private static func dogfood(
    _ id: DesignOSStoryID,
    _ title: String,
    _ summary: String,
    _ primaryKeyword: String,
    _ aliases: [String],
    _ intentQueries: [String],
    _ relatedStoryIDs: [DesignOSStoryID],
    _ usesDeliverableIDs: [RuntimeDeliverableID],
    _ file: String
  ) -> DesignOSStoryDescriptor {
    CatalogStoryRegistration.dogfood(
      id: id,
      title: title,
      summary: summary,
      primaryKeyword: primaryKeyword,
      aliases: aliases,
      intentQueries: intentQueries,
      relatedStoryIDs: relatedStoryIDs,
      usesDeliverableIDs: usesDeliverableIDs,
      examplePath: dogfoodRoot + file
    )
  }
}
