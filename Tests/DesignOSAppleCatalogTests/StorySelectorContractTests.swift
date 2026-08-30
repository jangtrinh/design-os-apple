import DesignOSApple
import Testing

@testable import DesignOSAppleCatalog

@Test("Selector admits the exact Settings story")
func selectorAdmitsSettings() throws {
  let selected = try DesignOSStorySelector.select(
    arguments: ["--design-os-story", "omniact.settings-shell"]
  )
  let selection = try #require(selected)
  #expect(selection.descriptor.id == .omniactSettingsShell)
  #expect(selection.profile == .default)
}

@Test("Selector admits the exact OmniAct command row with its profile")
func selectorAdmitsOmniActCommandRow() throws {
  let expectedProfile = try commandRowProfile()
  let selected = try DesignOSStorySelector.select(
    arguments: [
      "--design-os-story", "omniact.command-row", "--design-os-profile", "omniact",
    ]
  )
  let selection = try #require(selected)
  #expect(selection.descriptor.id == .omniactCommandRow)
  #expect(selection.profile == expectedProfile)
}

@Test("Selector admits the exact HUD story with its dedicated profile")
func selectorAdmitsOmniActHUD() throws {
  let selected = try DesignOSStorySelector.select(
    arguments: [
      "--design-os-story", "omniact.hud-autocomplete-material", "--design-os-profile",
      "omniact-hud",
    ]
  )
  let selection = try #require(selected)
  #expect(selection.descriptor.id == .omniactHUDAutocompleteMaterial)
  #expect(selection.profile.surfaceRole == .translucentContent)
  #expect(selection.profile.customContentCornerRadius == 18)
}

@Test("Selector admits the exact TocChien dictionary story")
func selectorAdmitsTocChienDictionary() throws {
  let selected = try DesignOSStorySelector.select(
    arguments: ["--design-os-story", "tocchien.dictionary-search"]
  )
  let selection = try #require(selected)
  #expect(selection.descriptor.id == .tocchienDictionarySearch)
  #expect(selection.descriptor.runtimeDeliverableID == .textSearchAndKeyboardInput)
  #expect(selection.profile == .default)
}

@Test("Selector admits the exact TocChien tabs and app-specific control")
func selectorAdmitsPhaseFiveTocChienStories() throws {
  let tabs = try #require(
    try DesignOSStorySelector.select(
      arguments: ["--design-os-story", "tocchien.navigation-tabs"]
    ))
  #expect(tabs.descriptor.id == .tocchienNavigationTabs)
  #expect(tabs.descriptor.owner == .runtimeImplementation)

  let control = try #require(
    try DesignOSStorySelector.select(
      arguments: ["--design-os-story", "tocchien.champion-hero-negative-control"]
    ))
  #expect(control.descriptor.id == .tocchienChampionHeroNegativeControl)
  #expect(control.descriptor.runtimeDeliverableID == nil)
  #expect(control.descriptor.owner == .appSpecific)
}

@Test("Profile registrations reject invalid and duplicate identifiers")
func profileRegistrationFailsClosed() throws {
  let custom = try commandRowProfile()
  #expect(throws: DesignOSProfileRegistryError.invalidIdentifier) {
    try DesignOSProfileRegistry(registrations: [.init(id: "Invalid", profile: .default)])
  }
  #expect(throws: DesignOSProfileRegistryError.duplicateIdentifier) {
    try DesignOSProfileRegistry(
      registrations: [
        .init(id: "same", profile: .default), .init(id: "same", profile: custom),
      ])
  }
  let registry = try DesignOSProfileRegistry(
    registrations: [.init(id: "custom", profile: custom)])
  #expect(try registry.profile(for: "custom") == custom)
  #expect(throws: DesignOSProfileRegistryError.unknownProfile) {
    try registry.profile(for: "missing")
  }
}

@Test("Profile registry owns bounded ASCII identifier grammar")
func profileIdentifierGrammarBoundaries() throws {
  let valid32 = "a" + String(repeating: "b", count: 31)
  let registry = try DesignOSProfileRegistry(
    registrations: [.init(id: valid32, profile: .default)])
  #expect(registry.identifiers == [valid32])

  for invalid in ["", "Uppercase", "đ", String(repeating: "a", count: 33), "with.dot"] {
    #expect(throws: DesignOSProfileRegistryError.invalidIdentifier) {
      try DesignOSProfileRegistry(registrations: [.init(id: invalid, profile: .default)])
    }
  }
}

@Test("Production catalog validates and exposes its exact profile registrations")
func productionProfileRegistryIsExact() throws {
  let expected: [String: DesignOSProfile] = [
    "default": .default,
    "omniact": try commandRowProfile(),
    "omniact-hud": try hudProfile(),
  ]
  let identifiers = DesignOSPilotCatalog.registeredProfileIdentifiers
  #expect(identifiers == ["default", "omniact", "omniact-hud"])
  for identifier in identifiers {
    #expect(try DesignOSPilotCatalog.profile(for: identifier) == expected[identifier])
  }
}

private func hudProfile() throws -> DesignOSProfile {
  try DesignOSProfile(
    fontDesign: .standard,
    titleSubtitleSpacing: 2,
    sidebarContentSpacing: 8,
    listRowContentSpacing: 12,
    customContentCornerRadius: 18,
    surfaceRole: .translucentContent
  )
}

@Test("Selector rejects malformed, duplicate, and unknown story inputs")
func selectorFailsClosed() {
  let cases: [([String], DesignOSStorySelectorError)] = [
    (["--design-os-story=omniact.settings-shell"], .storyArgument),
    (
      [
        "--design-os-story", "omniact.settings-shell", "--design-os-story",
        "omniact.settings-shell",
      ], .duplicateSelector
    ),
    (["--design-os-story", "unknown.story"], .unknown),
    (
      ["--design-os-story", "omniact.settings-shell", "--design-os-profile", "compact"],
      .profileUnknown
    ),
    (["--design-os-profile", "compact"], .storyArgument),
  ]
  for (arguments, expected) in cases {
    #expect(throws: expected) { try DesignOSStorySelector.select(arguments: arguments) }
  }
}

@Test("Injected admission seam retains unreachable unadmitted coverage")
func selectorRejectsUnadmittedStoryThroughInjectedAdmission() {
  let incompleteAdmission = Array(DesignOSPilotCatalog.admittedStories.dropLast())
  #expect(throws: DesignOSStorySelectorError.unadmitted) {
    try DesignOSStorySelector.select(
      arguments: ["--design-os-story", "tocchien.champion-hero-negative-control"],
      admittedStories: incompleteAdmission
    )
  }
}

@Test("Selector delegates invalid profile syntax to the profile registry")
func selectorRejectsInvalidProfileIdentifiers() {
  for profile in ["", "Uppercase", "đ", String(repeating: "a", count: 33), "with.dot"] {
    #expect(throws: DesignOSStorySelectorError.profileUnknown) {
      try DesignOSStorySelector.select(
        arguments: [
          "--design-os-story", "omniact.settings-shell", "--design-os-profile", profile,
        ])
    }
  }
}

private func commandRowProfile() throws -> DesignOSProfile {
  try DesignOSProfile(
    fontDesign: .expressive,
    titleSubtitleSpacing: 2,
    sidebarContentSpacing: 8,
    listRowContentSpacing: 10
  )
}
