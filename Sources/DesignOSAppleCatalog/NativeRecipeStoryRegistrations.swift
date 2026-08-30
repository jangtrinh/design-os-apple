enum NativeRecipeStoryRegistrations {
  static let values: [DesignOSStoryDescriptor] = [
    story(.buttonAndToolbarActions, "Buttons and toolbar actions", .buttonAndToolbarActions),
    story(.contentUnavailable, "Content unavailable", .contentUnavailable),
    story(.elevatedBackground, "Elevated background", .elevatedBackground),
    story(.hierarchicalStyle, "Hierarchical style", .hierarchicalStyle),
    story(.homeScreenQuickActions, "Home Screen quick actions", .homeScreenQuickActions),
    story(.listSidebarAndDisclosure, "Lists, sidebars, and disclosure", .listSidebarAndDisclosure),
    story(.materialAndGlassSurface, "Material and glass surface", .materialAndGlassSurface),
    story(
      .menuContextAndEditActions, "Menu, context, and edit actions", .menuContextAndEditActions),
    story(.navigationTabsAndToolbars, "Navigation, tabs, and toolbars", .navigationTabsAndToolbars),
    story(.pickerAndDateColorInput, "Picker, date, and color input", .pickerAndDateColorInput),
    story(.presentationAndShare, "Presentation and sharing", .presentationAndShare),
    story(.progressSliderStepper, "Progress, slider, and stepper", .progressSliderStepper),
    story(
      .textSearchAndKeyboardInput, "Text, search, and keyboard input", .textSearchAndKeyboardInput),
    story(.systemDeviceChromeHost, "System device chrome host", .systemDeviceChromeHost),
  ]

  private static func story(
    _ id: DesignOSStoryID,
    _ title: String,
    _ deliverableID: RuntimeDeliverableID
  ) -> DesignOSStoryDescriptor {
    CatalogStoryRegistration.canonical(
      id: id,
      title: title,
      summary: "Direct native API recipe with explicit ownership and fallback.",
      deliverableID: deliverableID
    )
  }
}
