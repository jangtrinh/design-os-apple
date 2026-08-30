import DesignOSAppleCatalog

enum DogfoodStoryPresentation: Equatable {
  case fullBleed
  case contained

  static func presentation(for id: DesignOSStoryID) -> Self {
    switch id {
    case .listRow, .sidebarRow, .listSidebarAndDisclosure,
      .navigationTabsAndToolbars, .pickerAndDateColorInput,
      .progressSliderStepper, .textSearchAndKeyboardInput,
      .omniactSettingsShell, .tocchienDictionarySearch, .tocchienNavigationTabs:
      .fullBleed
    case .profileCustomization, .colorRoles, .platformSemanticColor,
      .typographyRoles, .surfaceRoles, .accessorySlotLayout,
      .sectionContentLayout, .sidebarToolbarContent, .symbolContent,
      .buttonAndToolbarActions, .contentUnavailable, .elevatedBackground,
      .hierarchicalStyle, .homeScreenQuickActions, .materialAndGlassSurface,
      .menuContextAndEditActions, .presentationAndShare,
      .systemDeviceChromeHost, .extensionWidget, .extensionControlWidget,
      .omniactCommandRow, .omniactHUDAutocompleteMaterial,
      .tocchienChampionHeroNegativeControl:
      .contained
    }
  }
}
