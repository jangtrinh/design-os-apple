import DesignOSAppleCatalog
import Foundation
import Testing

@Test("Native API names and exact aliases resolve to existing recipe stories")
func nativeCapabilityExactLookup() throws {
  let expected: [(String, RuntimeDeliverableID, DesignOSStoryID)] = [
    ("Toggle", .progressSliderStepper, .progressSliderStepper),
    ("DatePicker", .pickerAndDateColorInput, .pickerAndDateColorInput),
    ("NavigationSplitView", .navigationTabsAndToolbars, .navigationTabsAndToolbars),
    ("TextField", .textSearchAndKeyboardInput, .textSearchAndKeyboardInput),
  ]
  for (api, deliverableID, storyID) in expected {
    let capability = try DesignOSNativeCapabilityIndex.resolve(api)
    #expect(capability.deliverable.id == deliverableID)
    #expect(capability.story.id == storyID)
    #expect(capability.coverage == .nativeSpecimen)
    #expect(try DesignOSNativeCapabilityIndex.resolve("SwiftUI.\(api)") == capability)
  }
  #expect(
    try DesignOSNativeCapabilityIndex.resolve("  DATE   picker  ").nativeAPI == "DatePicker")
  #expect(
    try DesignOSNativeCapabilityIndex.resolve("split view").nativeAPI == "NavigationSplitView")
}

@Test("Coverage distinguishes native calls from fixtures, documentation, and host requirements")
func nativeCapabilityHonestCoverage() throws {
  #expect(try DesignOSNativeCapabilityIndex.resolve("sheet").coverage == .nativeSpecimen)
  #expect(try DesignOSNativeCapabilityIndex.resolve("popover").coverage == .compileFixture)
  #expect(try DesignOSNativeCapabilityIndex.resolve("glassEffect").coverage == .nativeSpecimen)
  #expect(try DesignOSNativeCapabilityIndex.resolve("inspector").coverage == .documentationOnly)
  for api in ["WidgetKit.Widget", "ControlWidget", "UIApplicationShortcutItem"] {
    #expect(
      try DesignOSNativeCapabilityIndex.resolve(api).coverage == .hostIntegrationRequired)
  }
}

@Test("Native capability availability narrows broad recipe metadata where needed")
func nativeCapabilityAvailability() throws {
  let glass = try DesignOSNativeCapabilityIndex.resolve("glassEffect")
  #expect(glass.minimumAvailability.allSatisfy { $0.majorVersion == 26 })
  #expect(Set(glass.platforms) == Set(DesignOSPlatform.allCases))
  // The broad recipe still supports the floor through its material fallback.
  #expect(glass.deliverable.minimumAvailability.contains { $0.majorVersion == 17 })
  let cover = try DesignOSNativeCapabilityIndex.resolve("fullScreenCover")
  #expect(Set(cover.platforms) == Set([DesignOSPlatform.iOS, .iPadOS]))
  let control = try DesignOSNativeCapabilityIndex.resolve("ControlWidget")
  #expect(control.minimumAvailability.allSatisfy { $0.majorVersion == 18 })
  #expect(!control.platforms.contains(.macOS))
}

@Test("Native lookup does not invent missing controls or admit future SDK claims")
func nativeCapabilityUnknownTermsFailClosed() {
  for query in [
    "", "SecureField", "TextEditor", "Table", "Gauge", "PhotosPicker",
    "TabsPickerStyle", "textInputBorderShape", "concentricCornerRadii",
    "NSRefreshController", "iPhone Duo", "please build a toggle", "DatePicker(selection:)",
  ] {
    #expect(throws: DesignOSStoryDiscoveryError.notFound) {
      try DesignOSNativeCapabilityIndex.resolve(query)
    }
  }
}

@Test("Every native index term is collision-free and links to source evidence and authority")
func nativeCapabilitySourceRelationships() throws {
  let capabilities = DesignOSNativeCapabilityIndex.capabilities
  #expect(!capabilities.isEmpty)
  #expect(Set(capabilities.map(\.id)).count == capabilities.count)
  var normalizedTerms: Set<String> = []
  for capability in capabilities {
    #expect(
      capability.deliverable == DesignOSRuntimeCatalog.deliverables.first {
        $0.id == capability.deliverable.id
      })
    #expect(
      capability.story == DesignOSReleaseCatalog.stories.first { $0.id == capability.story.id })
    #expect(capability.story.runtimeDeliverableID == capability.deliverable.id)
    #expect(capability.documentationPath == capability.deliverable.documentationPath)
    #expect(!capability.minimumAvailability.isEmpty)
    #expect(Set(capability.platforms).count == capability.platforms.count)
    #expect(Set(capability.platforms).isSubset(of: Set(capability.deliverable.platforms)))
    for term in [capability.nativeAPI, capability.id] + capability.aliases {
      // All current API names and aliases are ASCII; exercise resolver normalization too.
      let normalized = term.lowercased()
        .split(whereSeparator: \.isWhitespace).joined(separator: " ")
      #expect(normalizedTerms.insert(normalized).inserted)
      #expect(try DesignOSNativeCapabilityIndex.resolve(term) == capability)
    }
    let source = try String(
      contentsOf: capabilityRepositoryRoot.appendingPathComponent(capability.evidencePath),
      encoding: .utf8)
    #expect(source.contains(capability.nativeAPI))
    switch capability.coverage {
    case .nativeSpecimen:
      #expect(capability.evidencePath == capability.story.examplePath)
    case .compileFixture, .hostIntegrationRequired:
      #expect(capability.evidencePath.hasPrefix("Tests/DesignOSAppleTests/"))
    case .documentationOnly:
      #expect(capability.evidencePath == capability.documentationPath)
    }
  }
}

@Test("API discovery preserves existing story resolution and release bundle bytes")
func nativeCapabilityDoesNotChangeReleaseProjection() throws {
  let before = try DesignOSStoryCatalogBundle.encoded()
  _ = try DesignOSNativeCapabilityIndex.resolve("Toggle")
  #expect(try DesignOSReleaseCatalog.resolve("list row").id == .listRow)
  #expect(throws: DesignOSStoryDiscoveryError.notFound) {
    try DesignOSReleaseCatalog.resolve("Toggle")
  }
  #expect(try DesignOSStoryCatalogBundle.encoded() == before)
  let checkedBundle = try Data(
    contentsOf: capabilityRepositoryRoot.appendingPathComponent(
      DesignOSStoryCatalogBundle.allowedRelativePath))
  #expect(try DesignOSStoryCatalogBundle.validatedExpectedBytes(from: checkedBundle) == before)
}

private var capabilityRepositoryRoot: URL {
  URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
}
