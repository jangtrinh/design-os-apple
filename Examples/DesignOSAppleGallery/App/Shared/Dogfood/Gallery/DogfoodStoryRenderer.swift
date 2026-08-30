import DesignOSAppleCatalog
import SwiftUI

enum DogfoodStoryRenderer {
  @ViewBuilder
  @MainActor
  static func render(descriptor: DesignOSStoryDescriptor) -> some View {
    switch descriptor.id {
    case .profileCustomization:
      ProfileCustomizationGallery()
    case .colorRoles:
      ColorRolesGallery()
    case .platformSemanticColor:
      PlatformSemanticColorGallery()
    case .typographyRoles:
      TypographyGallery()
    case .surfaceRoles:
      DesignOSSurfaceRoleGallery()
    case .listRow:
      DesignOSListRowGallery()
    case .sidebarRow:
      DesignOSSidebarRowGallery()
    case .accessorySlotLayout:
      AccessorySlotLayoutGallery()
    case .sectionContentLayout:
      SectionContentLayoutGallery()
    case .sidebarToolbarContent:
      SidebarToolbarContentGallery()
    case .symbolContent:
      SymbolContentGallery()
    case .buttonAndToolbarActions:
      NativeButtonAndToolbarActionRecipeGallery()
    case .contentUnavailable:
      NativeContentUnavailableViewRecipeGallery()
    case .elevatedBackground:
      NativeElevatedBackgroundRecipeGallery()
    case .hierarchicalStyle:
      NativeHierarchicalStyleRecipeGallery()
    case .homeScreenQuickActions:
      NativeHomeScreenQuickActionRecipeGallery()
    case .listSidebarAndDisclosure:
      NativeListSidebarAndDisclosureRecipeGallery()
    case .materialAndGlassSurface:
      NativeMaterialAndGlassSurfaceRecipeGallery()
    case .menuContextAndEditActions:
      NativeMenuContextAndEditActionsRecipeGallery()
    case .navigationTabsAndToolbars:
      NativeNavigationTabsAndToolbarsRecipeGallery()
    case .pickerAndDateColorInput:
      NativePickerAndDateColorInputRecipeGallery()
    case .presentationAndShare:
      NativePresentationAndShareRecipeGallery()
    case .progressSliderStepper:
      NativeProgressSliderStepperRecipeGallery()
    case .textSearchAndKeyboardInput:
      NativeTextSearchAndKeyboardInputRecipeGallery()
    case .systemDeviceChromeHost:
      SystemDeviceChromeHostRecipeGallery()
    case .extensionWidget:
      ExtensionWidgetRecipeGallery()
    case .extensionControlWidget:
      ExtensionControlWidgetRecipeGallery()
    case .omniactSettingsShell:
      OmniActSettingsStory()
    case .omniactCommandRow:
      OmniActCommandRowStory()
    case .omniactHUDAutocompleteMaterial:
      OmniActHUDAutocompleteMaterialStory()
    case .tocchienDictionarySearch:
      TocChienDictionarySearchStory()
    case .tocchienNavigationTabs:
      TocChienNavigationTabsStory()
    case .tocchienChampionHeroNegativeControl:
      TocChienChampionHeroNegativeControlStory()
    }
  }
}
