import DesignOSAppleCatalog
import Foundation
import Testing

@Test("Catalog bundle carries the complete release-candidate authority")
func bundleCarriesReleaseCandidateAuthority() throws {
  let data = try DesignOSStoryCatalogBundle.encoded()
  let text = try #require(String(data: data, encoding: .utf8))
  #expect(text.contains("\"deliverables\""))
  #expect(text.contains("\"runtimeDeliverable\""))
  #expect(text.contains("\"runtimeDeliverableIDs\""))
  #expect(text.contains("\"storyIDs\""))
  for id in RuntimeDeliverableID.allCases {
    #expect(text.contains("\"\(id.rawValue)\""))
  }
  for id in DesignOSStoryID.allCases {
    #expect(text.contains("\"\(id.rawValue)\""))
  }
  for field in [
    "module", "symbolOrNativeAPI", "platforms", "minimumAvailability", "fallback",
    "customizationAxes", "stateOwner", "accessibilityOwner", "documentationPath",
    "examplePath", "storyDisposition", "verificationCommand",
  ] {
    #expect(text.contains("\"\(field)\""))
  }
  #expect(text.contains("omniact.settings-shell"))
  #expect(text.contains("omniact.command-row"))
  #expect(text.contains("omniact.hud-autocomplete-material"))
  #expect(text.contains("tocchien.dictionary-search"))
  #expect(text.contains("tocchien.navigation-tabs"))
  #expect(text.contains("tocchien.champion-hero-negative-control"))
  #expect(text.contains("RUNTIME_IMPLEMENTATION"))
  #expect(text.contains("APP_SPECIFIC"))
  #expect(text.contains("materialAndGlassSurface"))
  #expect(text.contains("textSearchAndKeyboardInput"))
  #expect(text.contains("navigationTabsAndToolbars"))
  #expect(text.contains("manifestSHA256"))
  #expect(text.contains("schemaSHA256"))
  #expect(text.contains("\"envelope\""))
  #expect(text.contains("\"story\""))
  #expect(text.contains("additionalProperties"))
  #expect(text.contains("\"owner\""))
  #expect(try DesignOSStoryCatalogBundle.validatedExpectedBytes(from: data) == data)
}

@Test("Catalog bundle excludes product geometry control and command state")
func bundleExcludesProductStateFields() throws {
  let data = try DesignOSStoryCatalogBundle.encoded()
  let text = try #require(String(data: data, encoding: .utf8))
  for forbidden in ["panelWidth", "rowCapacity", "providerName", "materialChoice", "commandState"] {
    #expect(!text.contains(forbidden))
  }
}

@Test("Bundle rejects stale manifest, digest, and schema payloads")
func bundleRejectsStalePayloads() throws {
  let original = try DesignOSStoryCatalogBundle.encoded()
  let text = try #require(String(data: original, encoding: .utf8))
  let staleTexts = [
    text.replacingOccurrences(
      of: "\"summary\":\"Native macOS settings navigation, values, and actions.\"",
      with: "\"summary\":\"Changed\""),
    text.replacingOccurrences(of: "\"manifestSHA256\":\"", with: "\"manifestSHA256\":\"0"),
    text.replacingOccurrences(of: "\"schemaVersion\":1", with: "\"schemaVersion\":2"),
  ]
  for staleText in staleTexts {
    let stale = Data(staleText.utf8)
    #expect(throws: DesignOSStoryCatalogBundle.BundleError.self) {
      try DesignOSStoryCatalogBundle.validatedExpectedBytes(from: stale)
    }
  }
}

@Test("Bundle rejects stale bytes without accepting a second catalog authority")
func bundleRejectsStaleBytes() throws {
  let original = try DesignOSStoryCatalogBundle.encoded()
  var stale = original
  stale[stale.startIndex] = 91
  #expect(throws: DesignOSStoryCatalogBundle.BundleError.self) {
    try DesignOSStoryCatalogBundle.validatedExpectedBytes(from: stale)
  }
}
