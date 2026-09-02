enum NativeRecipeStoryRegistrations {
  static let values: [DesignOSStoryDescriptor] = [
    story(
      .buttonAndToolbarActions, "Buttons and toolbar actions",
      "Use native buttons and toolbar placements for contextual actions without custom controls.",
      "toolbar actions", ["button actions"],
      ["add a toolbar action"], [.menuContextAndEditActions, .navigationTabsAndToolbars],
      .buttonAndToolbarActions),
    story(
      .contentUnavailable, "Content unavailable",
      "Use ContentUnavailableView when a search or collection has no presentable results.",
      "empty state", ["content unavailable"],
      ["show an empty state"], [.listRow, .textSearchAndKeyboardInput], .contentUnavailable),
    story(
      .elevatedBackground, "Elevated background",
      "Use native grouped backgrounds to separate elevated content from its surrounding surface.",
      "elevated background", ["grouped background"],
      ["add an elevated background"], [.surfaceRoles, .materialAndGlassSurface], .elevatedBackground
    ),
    story(
      .hierarchicalStyle, "Hierarchical style",
      "Use hierarchical foreground styles when an icon or label needs subordinate emphasis.",
      "hierarchical style", ["secondary emphasis"],
      ["apply hierarchical styling"], [.symbolContent, .colorRoles], .hierarchicalStyle),
    story(
      .homeScreenQuickActions, "Home Screen quick actions",
      "Use home-screen quick actions to expose a small set of launch-time app tasks.",
      "home screen actions", ["quick actions"],
      ["add home screen actions"], [.extensionWidget, .systemDeviceChromeHost],
      .homeScreenQuickActions),
    story(
      .listSidebarAndDisclosure, "Lists, sidebars, and disclosure",
      "Use native lists, sidebars, and disclosure patterns for navigable hierarchical collections.",
      "list sidebar", ["disclosure list"],
      ["build a sidebar list"], [.listRow, .sidebarRow], .listSidebarAndDisclosure),
    story(
      .materialAndGlassSurface, "Material and glass surface",
      "Use native material or glass surfaces when translucency conveys spatial context.",
      "material surface", ["glass surface"],
      ["use material backgrounds"], [.surfaceRoles, .elevatedBackground], .materialAndGlassSurface),
    story(
      .menuContextAndEditActions, "Menu, context, and edit actions",
      "Use menus, context actions, and edit commands for compact secondary operations.",
      "context menu", ["edit actions"],
      ["add a context menu"], [.buttonAndToolbarActions, .presentationAndShare],
      .menuContextAndEditActions),
    story(
      .navigationTabsAndToolbars, "Navigation, tabs, and toolbars",
      "Use native navigation, tabs, and toolbars to organize app destinations and commands.",
      "navigation tabs", ["tab toolbar"],
      ["build tab navigation"], [.buttonAndToolbarActions, .listSidebarAndDisclosure],
      .navigationTabsAndToolbars),
    story(
      .pickerAndDateColorInput, "Picker, date, and color input",
      "Use native pickers for bounded choices, dates, and color input with platform behavior.",
      "date color input", ["native picker"],
      ["collect date or color input"], [.progressSliderStepper, .textSearchAndKeyboardInput],
      .pickerAndDateColorInput),
    story(
      .presentationAndShare, "Presentation and sharing",
      "Use sheets, popovers, and sharing APIs to present transient tasks and export actions.",
      "share sheet", ["presentation actions"],
      ["present sharing actions"], [.menuContextAndEditActions, .navigationTabsAndToolbars],
      .presentationAndShare),
    story(
      .progressSliderStepper, "Progress, slider, and stepper",
      "Use progress, sliders, and steppers for visible status and bounded value adjustment.",
      "progress controls", ["slider stepper"],
      ["show progress controls"], [.pickerAndDateColorInput, .buttonAndToolbarActions],
      .progressSliderStepper),
    story(
      .textSearchAndKeyboardInput, "Text, search, and keyboard input",
      "Use native text and search input for typing, focus, keyboard, and search behavior.",
      "search input", ["text field"],
      ["add searchable text input"], [.contentUnavailable, .pickerAndDateColorInput],
      .textSearchAndKeyboardInput),
    story(
      .systemDeviceChromeHost, "System device chrome host",
      "Use native scenes, safe-area APIs, symbols, and services to host system device chrome.",
      "device chrome", ["system chrome"],
      ["host system device chrome"], [.homeScreenQuickActions, .navigationTabsAndToolbars],
      .systemDeviceChromeHost),
  ]

  private static func story(
    _ id: DesignOSStoryID,
    _ title: String,
    _ summary: String,
    _ primaryKeyword: String,
    _ aliases: [String],
    _ intentQueries: [String],
    _ relatedStoryIDs: [DesignOSStoryID],
    _ deliverableID: RuntimeDeliverableID
  ) -> DesignOSStoryDescriptor {
    CatalogStoryRegistration.canonical(
      id: id,
      title: title,
      summary: summary,
      kind: .nativeRecipe,
      primaryKeyword: primaryKeyword,
      aliases: aliases,
      intentQueries: intentQueries,
      relatedStoryIDs: relatedStoryIDs,
      deliverableID: deliverableID
    )
  }
}
