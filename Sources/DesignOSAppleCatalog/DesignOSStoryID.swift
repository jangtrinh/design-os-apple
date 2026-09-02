/// Stable identities for executable Gallery stories and retained compatibility routes.
public enum DesignOSStoryID: String, CaseIterable, Codable, Hashable, Sendable {
  case profileCustomization = "foundation.profile-customization"
  case colorRoles = "foundation.color-roles"
  case platformSemanticColor = "foundation.platform-semantic-color"
  case typographyRoles = "foundation.typography"
  case surfaceRoles = "foundation.surface-roles"
  case listRow = "component.list-row"
  case sidebarRow = "component.sidebar-row"
  case accessorySlotLayout = "primitive.accessory-slot-layout"
  case sectionContentLayout = "primitive.section-content-layout"
  case sidebarToolbarContent = "primitive.sidebar-toolbar-content"
  case symbolContent = "primitive.symbol-content"
  case buttonAndToolbarActions = "native.button-toolbar-actions"
  case contentUnavailable = "native.content-unavailable"
  case elevatedBackground = "native.elevated-background"
  case hierarchicalStyle = "native.hierarchical-style"
  case homeScreenQuickActions = "native.home-screen-quick-actions"
  case listSidebarAndDisclosure = "native.list-sidebar-disclosure"
  case materialAndGlassSurface = "native.material-glass-surface"
  case menuContextAndEditActions = "native.menu-context-edit-actions"
  case navigationTabsAndToolbars = "native.navigation-tabs-toolbars"
  case pickerAndDateColorInput = "native.picker-date-color-input"
  case presentationAndShare = "native.presentation-share"
  case progressSliderStepper = "native.progress-slider-stepper"
  case textSearchAndKeyboardInput = "native.text-search-keyboard-input"
  case systemDeviceChromeHost = "native.system-device-chrome-host"
  case extensionWidget = "extension.widget"
  case extensionControlWidget = "extension.control-widget"
  case omniactSettingsShell = "omniact.settings-shell"
  case omniactCommandRow = "omniact.command-row"
  /// Historical identity retained for source compatibility; no longer an admitted story.
  @available(
    *, deprecated, message: "The HUD story is no longer part of the current release catalog."
  )
  case omniactHUDAutocompleteMaterial = "omniact.hud-autocomplete-material"
  case tocchienDictionarySearch = "tocchien.dictionary-search"
  case tocchienNavigationTabs = "tocchien.navigation-tabs"
  case tocchienChampionHeroNegativeControl = "tocchien.champion-hero-negative-control"

  /// All identities, including deprecated compatibility routes.
  public static let allCases: [Self] = [
    .profileCustomization, .colorRoles, .platformSemanticColor, .typographyRoles, .surfaceRoles,
    .listRow, .sidebarRow, .accessorySlotLayout, .sectionContentLayout, .sidebarToolbarContent,
    .symbolContent, .buttonAndToolbarActions, .contentUnavailable, .elevatedBackground,
    .hierarchicalStyle, .homeScreenQuickActions, .listSidebarAndDisclosure,
    .materialAndGlassSurface, .menuContextAndEditActions, .navigationTabsAndToolbars,
    .pickerAndDateColorInput, .presentationAndShare, .progressSliderStepper,
    .textSearchAndKeyboardInput, .systemDeviceChromeHost, .extensionWidget,
    .extensionControlWidget, .omniactSettingsShell, .omniactCommandRow,
    Self(rawValue: "omniact.hud-autocomplete-material")!, .tocchienDictionarySearch,
    .tocchienNavigationTabs, .tocchienChampionHeroNegativeControl,
  ]

  /// The exact 32 identities admitted by the current release catalog and v2 bundle.
  public static let currentExecutableCases = allCases.filter {
    $0.rawValue != "omniact.hud-autocomplete-material"
  }
}
