# ``DesignOSApple``

Build Apple-platform interfaces from semantic content roles and direct SwiftUI calls.

## Overview

DesignOSApple keeps Apple-owned controls, containers, presentation, and system chrome at the call site. The package provides adaptive color and typography roles, a small set of content-only compositions, and metadata recipes that document which native API owns behavior.

## Topics

### Foundations

- <doc:Color-Roles>
- <doc:Typography>
- <doc:Surface-Roles>
- <doc:Platform-Semantic-Color>
- <doc:Profiles-and-Dogfood-Catalog>

### Semantic components

- ``DesignOSListRow``
- ``DesignOSSidebarRow``

### Package-internal composition primitives

- <doc:AccessorySlotLayout>
- <doc:SectionContentLayout>
- <doc:SidebarToolbarContent>
- <doc:SymbolContent>

### Native recipes

- ``NativeButtonAndToolbarActionRecipe``
- ``NativeContentUnavailableViewRecipe``
- ``NativeElevatedBackgroundRecipe``
- ``NativeHierarchicalStyleRecipe``
- ``NativeHomeScreenQuickActionRecipe``
- ``NativeListSidebarAndDisclosureRecipe``
- ``NativeMaterialAndGlassSurfaceRecipe``
- ``NativeMenuContextAndEditActionsRecipe``
- ``NativeNavigationTabsAndToolbarsRecipe``
- ``NativePickerAndDateColorInputRecipe``
- ``NativePresentationAndShareRecipe``
- ``NativeProgressSliderStepperRecipe``
- ``NativeTextSearchAndKeyboardInputRecipe``
- ``SystemDeviceChromeHostRecipe``

### Extension recipes

- <doc:ExtensionWidgetRecipe>
- <doc:ExtensionControlWidgetRecipe>
