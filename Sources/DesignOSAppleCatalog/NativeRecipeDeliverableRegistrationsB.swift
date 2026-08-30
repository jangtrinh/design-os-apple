enum NativeRecipeDeliverableRegistrationsB {
  static let values: [RuntimeDeliverableDescriptor] = [
    recipe(
      .menuContextAndEditActions,
      "NativeMenuContextAndEditActionsRecipe",
      "Menu and contextMenu remain direct native calls.",
      "NativeMenuContextAndEditActionsRecipe.md",
      "NativeMenuContextAndEditActionsRecipeGallery.swift",
      .menuContextAndEditActions
    ),
    recipe(
      .navigationTabsAndToolbars,
      "NativeNavigationTabsAndToolbarsRecipe",
      "NavigationStack, TabView, and toolbar remain direct calls.",
      "NativeNavigationTabsAndToolbarsRecipe.md",
      "NativeNavigationTabsAndToolbarsRecipeGallery.swift",
      .navigationTabsAndToolbars
    ),
    recipe(
      .pickerAndDateColorInput,
      "NativePickerAndDateColorInputRecipe",
      "Picker, DatePicker, and ColorPicker retain their native styles.",
      "NativePickerAndDateColorInputRecipe.md",
      "NativePickerAndDateColorInputRecipeGallery.swift",
      .pickerAndDateColorInput
    ),
    recipe(
      .presentationAndShare,
      "NativePresentationAndShareRecipe",
      "Use the supported native presentation or ShareLink directly.",
      "NativePresentationAndShareRecipe.md",
      "NativePresentationAndShareRecipeGallery.swift",
      .presentationAndShare
    ),
    recipe(
      .progressSliderStepper,
      "NativeProgressSliderStepperRecipe",
      "Native controls own geometry, focus, and accessible values.",
      "NativeProgressSliderStepperRecipe.md",
      "NativeProgressSliderStepperRecipeGallery.swift",
      .progressSliderStepper
    ),
    recipe(
      .textSearchAndKeyboardInput,
      "NativeTextSearchAndKeyboardInputRecipe",
      "TextField and searchable remain direct native calls.",
      "NativeTextSearchAndKeyboardInputRecipe.md",
      "NativeTextSearchAndKeyboardInputRecipeGallery.swift",
      .textSearchAndKeyboardInput
    ),
    recipe(
      .systemDeviceChromeHost,
      "SystemDeviceChromeHostRecipe",
      "The system host owns device, scene, keyboard, and window chrome.",
      "SystemDeviceChromeHostRecipe.md",
      "SystemDeviceChromeHostRecipeGallery.swift",
      .systemDeviceChromeHost
    ),
  ]

  private static func recipe(
    _ id: RuntimeDeliverableID,
    _ symbol: String,
    _ fallback: String,
    _ documentation: String,
    _ example: String,
    _ storyID: DesignOSStoryID
  ) -> RuntimeDeliverableDescriptor {
    CatalogRegistrationDefaults.runtime(
      id: id,
      symbol: symbol,
      fallback: fallback,
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/\(documentation)",
      examplePath: "Examples/DesignOSAppleGallery/\(example)",
      storyID: storyID
    )
  }
}
