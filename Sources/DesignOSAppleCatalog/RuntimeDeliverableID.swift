import DesignOSApple
import SwiftUI

/// The closed identity set for cataloged runtime deliverables.
public enum RuntimeDeliverableID: String, CaseIterable, Codable, Hashable, Sendable {
  case designOSProfile
  case designOSColorRole
  case platformSemanticColor
  case designOSTypographyRole
  case designOSSurfaceRole
  case designOSListRow
  case designOSSidebarRow
  case accessorySlotLayout
  case sectionContentLayout
  case sidebarToolbarContent
  case symbolContent
  case buttonAndToolbarActions
  case contentUnavailable
  case elevatedBackground
  case hierarchicalStyle
  case homeScreenQuickActions
  case listSidebarAndDisclosure
  case materialAndGlassSurface
  case menuContextAndEditActions
  case navigationTabsAndToolbars
  case pickerAndDateColorInput
  case presentationAndShare
  case progressSliderStepper
  case textSearchAndKeyboardInput
  case systemDeviceChromeHost
  case extensionWidget
  case extensionControlWidget

  /// Resolves the associated public runtime symbol at compile time.
  public func resolvesCompiledRuntimeSymbol() {
    switch self {
    case .designOSProfile:
      _ = DesignOSProfile.self
    case .designOSColorRole, .platformSemanticColor:
      _ = DesignOSColorRole.self
    case .designOSTypographyRole:
      _ = DesignOSTypographyRole.self
    case .designOSSurfaceRole:
      _ = DesignOSSurfaceRole.self
    case .designOSListRow:
      _ = DesignOSListRow<EmptyView, Text, EmptyView, EmptyView>.self
    case .designOSSidebarRow:
      _ = DesignOSSidebarRow<Text, EmptyView>.self
    case .accessorySlotLayout:
      _ = AccessorySlotLayout<EmptyView>.self
    case .sectionContentLayout:
      _ = SectionContentLayout<Text, EmptyView>.self
    case .sidebarToolbarContent:
      _ = SidebarToolbarContent<Text, EmptyView>.self
    case .symbolContent:
      _ = SymbolContent<EmptyView>.self
    case .buttonAndToolbarActions:
      _ = NativeButtonAndToolbarActionRecipe.self
    case .contentUnavailable:
      _ = NativeContentUnavailableViewRecipe.self
    case .elevatedBackground:
      _ = NativeElevatedBackgroundRecipe.self
    case .hierarchicalStyle:
      _ = NativeHierarchicalStyleRecipe.self
    case .homeScreenQuickActions:
      _ = NativeHomeScreenQuickActionRecipe.self
    case .listSidebarAndDisclosure:
      _ = NativeListSidebarAndDisclosureRecipe.self
    case .materialAndGlassSurface:
      _ = NativeMaterialAndGlassSurfaceRecipe.self
    case .menuContextAndEditActions:
      _ = NativeMenuContextAndEditActionsRecipe.self
    case .navigationTabsAndToolbars:
      _ = NativeNavigationTabsAndToolbarsRecipe.self
    case .pickerAndDateColorInput:
      _ = NativePickerAndDateColorInputRecipe.self
    case .presentationAndShare:
      _ = NativePresentationAndShareRecipe.self
    case .progressSliderStepper:
      _ = NativeProgressSliderStepperRecipe.self
    case .textSearchAndKeyboardInput:
      _ = NativeTextSearchAndKeyboardInputRecipe.self
    case .systemDeviceChromeHost:
      _ = SystemDeviceChromeHostRecipe.self
    case .extensionWidget, .extensionControlWidget:
      break
    }
  }
}
