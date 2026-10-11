enum NativeControlCapabilityRegistrations {
  static let values: [DesignOSNativeCapability] = [
    .init(nativeAPI: "Button", aliases: ["native button"], deliverableID: .buttonAndToolbarActions),
    .init(
      nativeAPI: "ToolbarItem",
      aliases: ["toolbar item"],
      deliverableID: .navigationTabsAndToolbars
    ),
    .init(
      nativeAPI: "ContentUnavailableView",
      aliases: ["empty state"],
      deliverableID: .contentUnavailable
    ),
    .init(nativeAPI: "List", aliases: ["native list"], deliverableID: .listSidebarAndDisclosure),
    .init(
      nativeAPI: "DisclosureGroup",
      aliases: ["disclosure group"],
      deliverableID: .listSidebarAndDisclosure
    ),
    .init(nativeAPI: "Menu", aliases: ["native menu"], deliverableID: .menuContextAndEditActions),
    .init(
      nativeAPI: "contextMenu",
      aliases: ["context menu"],
      deliverableID: .menuContextAndEditActions
    ),
    .init(
      nativeAPI: "swipeActions", aliases: ["swipe actions"],
      deliverableID: .menuContextAndEditActions,
      coverage: .compileFixture,
      evidencePath: "Tests/DesignOSAppleTests/NativeMenuContextAndEditActionsRecipeTests.swift"
    ),
    .init(
      nativeAPI: "NavigationStack",
      aliases: ["navigation stack"],
      deliverableID: .navigationTabsAndToolbars
    ),
    .init(
      nativeAPI: "NavigationSplitView",
      aliases: ["navigation split view", "split view"],
      deliverableID: .navigationTabsAndToolbars
    ),
    .init(
      nativeAPI: "NavigationLink",
      aliases: ["navigation link"],
      deliverableID: .navigationTabsAndToolbars
    ),
    .init(nativeAPI: "TabView", aliases: ["tab view"], deliverableID: .navigationTabsAndToolbars),
    .init(nativeAPI: "Picker", aliases: ["native picker"], deliverableID: .pickerAndDateColorInput),
    .init(
      nativeAPI: "DatePicker",
      aliases: ["date picker"],
      deliverableID: .pickerAndDateColorInput
    ),
    .init(
      nativeAPI: "ColorPicker",
      aliases: ["color picker"],
      deliverableID: .pickerAndDateColorInput
    ),
    .init(nativeAPI: "Toggle", aliases: ["native toggle"], deliverableID: .progressSliderStepper),
    .init(
      nativeAPI: "ProgressView",
      aliases: ["progress view"],
      deliverableID: .progressSliderStepper
    ),
    .init(nativeAPI: "Slider", aliases: ["native slider"], deliverableID: .progressSliderStepper),
    .init(nativeAPI: "Stepper", aliases: ["native stepper"], deliverableID: .progressSliderStepper),
    .init(
      nativeAPI: "TextField",
      aliases: ["text field"],
      deliverableID: .textSearchAndKeyboardInput
    ),
    .init(
      nativeAPI: "searchable",
      aliases: ["search input"],
      deliverableID: .textSearchAndKeyboardInput
    ),
    .init(
      nativeAPI: "FocusState", aliases: ["focus state"], deliverableID: .textSearchAndKeyboardInput,
      coverage: .compileFixture,
      evidencePath: "Tests/DesignOSAppleTests/NativeTextSearchAndKeyboardInputRecipeTests.swift"
    ),
    .init(
      nativeAPI: "scrollDismissesKeyboard", aliases: ["keyboard dismissal"],
      deliverableID: .textSearchAndKeyboardInput, coverage: .compileFixture,
      evidencePath: "Tests/DesignOSAppleTests/NativeTextSearchAndKeyboardInputRecipeTests.swift"
    ),
  ]
}
