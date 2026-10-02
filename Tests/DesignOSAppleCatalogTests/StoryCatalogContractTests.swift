import CryptoKit
import DesignOSAppleCatalog
import Foundation
import Testing

@Test("The release catalog admits every closed story ID exactly once")
func releaseCandidateDescriptorsAreAdmitted() {
  let descriptors = DesignOSReleaseCatalog.stories
  #expect(descriptors.map(\.id) == DesignOSStoryID.currentExecutableCases)
  #expect(Set(descriptors.map(\.id)).count == descriptors.count)
  #expect(descriptors.count == 32)
  #expect(
    descriptors.first(where: { $0.id == .omniactSettingsShell })?.runtimeDeliverableID
      == .listSidebarAndDisclosure)
  #expect(
    descriptors.first(where: { $0.id == .omniactCommandRow })?.runtimeDeliverableID
      == .designOSListRow)
  #expect(
    descriptors.first(where: { $0.id == .tocchienDictionarySearch })?.runtimeDeliverableID
      == .textSearchAndKeyboardInput)
  #expect(
    descriptors.first(where: { $0.id == .tocchienNavigationTabs })?.runtimeDeliverableID
      == .navigationTabsAndToolbars)
  #expect(descriptors.filter { $0.runtimeDeliverableID != nil }.count == 31)
  #expect(descriptors.filter { $0.owner == .runtimeImplementation }.count == 27)
  #expect(
    descriptors.first(where: { $0.id == .tocchienChampionHeroNegativeControl })?
      .runtimeDeliverableID
      == nil)
  #expect(
    descriptors.first(where: { $0.id == .tocchienChampionHeroNegativeControl })?.owner
      == .appSpecific)
  for descriptor in descriptors {
    #expect(!descriptor.examplePath.isEmpty)
    #expect(FileManager.default.fileExists(atPath: descriptor.examplePath))
    #expect(
      descriptor.owner == descriptor.relationship.owner)
  }
  for deliverableID in descriptors.compactMap(\.runtimeDeliverableID) {
    deliverableID.resolvesCompiledRuntimeSymbol()
  }
}

@Test("The dogfood pilot preserves the owner-approved five-story evidence boundary")
func dogfoodPilotPreservesCurrentStorySet() {
  #expect(
    DesignOSPilotCatalog.admittedStories.map(\.id) == [
      .omniactSettingsShell,
      .omniactCommandRow,
      .tocchienDictionarySearch,
      .tocchienNavigationTabs,
      .tocchienChampionHeroNegativeControl,
    ])
}

@Test("Discovery resolves exact stable IDs, primary keywords, and aliases in order")
func discoveryResolvesHumanTermsWithoutFuzzyMatching() throws {
  #expect(try DesignOSReleaseCatalog.resolve("component.list-row").id == .listRow)
  #expect(try DesignOSReleaseCatalog.resolve("list row").id == .listRow)
  #expect(try DesignOSReleaseCatalog.resolve("empty state").id == .contentUnavailable)
  #expect(throws: DesignOSStoryDiscoveryError.notFound) {
    try DesignOSReleaseCatalog.resolve("list rows")
  }
}

@Test("Discovery metadata and relationship validation fail closed")
func discoveryValidationFailsClosed() throws {
  #expect(throws: DesignOSStoryDiscoveryMetadataError.invalidPrimaryKeyword) {
    try DesignOSStoryDiscovery(
      primaryKeyword: "one two three four five", aliases: [], intentQueries: ["use this"])
  }
  #expect(throws: DesignOSStoryDiscoveryMetadataError.invalidIntentQueries) {
    try DesignOSStoryDiscovery(primaryKeyword: "valid", aliases: [], intentQueries: [])
  }

  let first = DesignOSReleaseCatalog.stories[0]
  let second = DesignOSReleaseCatalog.stories[1]
  let collidingDescriptor = try DesignOSStoryDescriptor(
    id: second.id, title: second.title, summary: second.summary, kind: second.kind,
    discovery: DesignOSStoryDiscovery(
      primaryKeyword: first.discovery.primaryKeyword, aliases: [], intentQueries: ["other intent"]),
    relationship: second.relationship, relatedStoryIDs: second.relatedStoryIDs,
    examplePath: second.examplePath)
  var duplicateTerms = DesignOSReleaseCatalog.stories
  duplicateTerms[1] = collidingDescriptor
  #expect(throws: DesignOSReleaseCatalogError.duplicateDiscoveryTerm) {
    try DesignOSReleaseCatalog.validate(duplicateTerms)
  }
  #expect(throws: DesignOSStoryDiscoveryError.ambiguous) {
    try DesignOSReleaseCatalog.resolve(
      first.discovery.primaryKeyword, in: [first, collidingDescriptor])
  }
  #expect(throws: DesignOSStoryDiscoveryError.ambiguous) {
    try DesignOSReleaseCatalog.resolve(first.id.rawValue, in: [first, first])
  }

  let descriptor = first
  #expect(throws: DesignOSStoryDescriptorError.invalidRelatedStoryIDs) {
    try DesignOSStoryDescriptor(
      id: descriptor.id, title: descriptor.title, summary: descriptor.summary,
      kind: descriptor.kind,
      discovery: descriptor.discovery, relationship: descriptor.relationship,
      relatedStoryIDs: [descriptor.id], examplePath: descriptor.examplePath)
  }
}

@Test("Product demos remain app-owned even when they use runtime deliverables")
func productStoriesDeriveAppOwnershipFromRelationship() {
  let productStories = DesignOSReleaseCatalog.stories.filter { $0.kind == .productDemo }
  #expect(productStories.count == 5)
  #expect(productStories.allSatisfy { $0.owner == .appSpecific })
  #expect(
    productStories.allSatisfy {
      $0.runtimeDeliverableID != nil || $0.usedRuntimeDeliverableIDs.isEmpty
    })
}

@Test("Native recipes carry distinct application summaries")
func nativeRecipeSummariesAreInformative() {
  let summaries = DesignOSReleaseCatalog.stories
    .filter { $0.kind == .nativeRecipe }
    .map(\.summary)
  #expect(summaries.count == 14)
  #expect(Set(summaries).count == summaries.count)
  #expect(!summaries.contains("Direct native API recipe with explicit ownership and fallback."))
}

@Test("The frozen v1 bundle remains byte-identical to its compatibility baseline")
func frozenV1BundleRemainsByteIdentical() throws {
  let data = try Data(
    contentsOf: URL(
      fileURLWithPath:
        "Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v1.json"))
  let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  #expect(digest == "c2fe6d5efebd582a08627c610ef73069349a633334304c50ed48810ad4e12676")
}

@Test("Legacy HUD identity and descriptor initializer remain source-compatible")
func legacyHUDIdentityAndDescriptorInitializerRemainAvailable() {
  #expect(
    DesignOSStoryID.allCases.contains {
      $0.rawValue == "omniact.hud-autocomplete-material"
    })
  let descriptor = DesignOSStoryDescriptor(
    id: DesignOSStoryID(rawValue: "omniact.hud-autocomplete-material")!,
    title: "HUD autocomplete",
    summary: "Legacy caller compatibility.",
    runtimeDeliverableID: .materialAndGlassSurface,
    examplePath:
      "Examples/DesignOSAppleGallery/App/Shared/Dogfood/Shared/OmniActHUDAutocompleteMaterialStory.swift"
  )
  #expect(descriptor.runtimeDeliverableID == .materialAndGlassSurface)
  #expect(
    !DesignOSReleaseCatalog.stories.contains {
      $0.id.rawValue == "omniact.hud-autocomplete-material"
    })
}

@Test("Discovery terms cannot shadow stable story ID namespaces")
func discoveryTermsCannotShadowStoryIDs() throws {
  var descriptors = DesignOSReleaseCatalog.stories
  let original = descriptors[0]
  descriptors[0] = try DesignOSStoryDescriptor(
    id: original.id, title: original.title, summary: original.summary, kind: original.kind,
    discovery: DesignOSStoryDiscovery(
      primaryKeyword: "component.list-row", aliases: [], intentQueries: ["shadow an ID"]),
    relationship: original.relationship, relatedStoryIDs: original.relatedStoryIDs,
    examplePath: original.examplePath)
  #expect(throws: DesignOSReleaseCatalogError.discoveryTermConflictsWithStoryID) {
    try DesignOSReleaseCatalog.validate(descriptors)
  }
}

@Test("Discovery decoding rejects metadata the validated initializer rejects")
func discoveryDecodingUsesValidatedInitialization() {
  let invalidPrimaryKeyword = Data(
    "{\"primaryKeyword\":\"one two three four five\",\"aliases\":[],\"intentQueries\":[]}".utf8)
  #expect(throws: DesignOSStoryDiscoveryMetadataError.invalidPrimaryKeyword) {
    try JSONDecoder().decode(DesignOSStoryDiscovery.self, from: invalidPrimaryKeyword)
  }
  let invalidAliases = Data(
    "{\"primaryKeyword\":\"valid\",\"aliases\":[\"same\",\"same\"],\"intentQueries\":[\"use valid\"]}"
      .utf8)
  #expect(throws: DesignOSStoryDiscoveryMetadataError.invalidAliases) {
    try JSONDecoder().decode(DesignOSStoryDiscovery.self, from: invalidAliases)
  }
  let invalidIntentQueries = Data(
    "{\"primaryKeyword\":\"valid\",\"aliases\":[],\"intentQueries\":[]}".utf8)
  #expect(throws: DesignOSStoryDiscoveryMetadataError.invalidIntentQueries) {
    try JSONDecoder().decode(DesignOSStoryDiscovery.self, from: invalidIntentQueries)
  }
}

@Test("Story descriptor decoding enforces validation precedence and compatibility bounds")
func storyDescriptorDecodingEnforcesValidationPrecedenceAndCompatibility() throws {
  let original = try #require(
    DesignOSReleaseCatalog.stories.first {
      $0.owner == .runtimeImplementation
        && $0.runtimeDeliverableID != nil
        && !$0.relatedStoryIDs.isEmpty
    }
  )
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  // 1. Valid round-trip encode and decode
  let validData = try encoder.encode(original)
  let decoded = try decoder.decode(DesignOSStoryDescriptor.self, from: validData)
  #expect(decoded == original)

  let validJson = try #require(String(data: validData, encoding: .utf8))
  let deliverableID = try #require(original.runtimeDeliverableID?.rawValue)

  // 2. Owner mismatch: relationship is runtimeImplementation, but owner claims appSpecific
  let ownerMismatchJson = validJson.replacingOccurrences(
    of: "\"owner\":\"RUNTIME_IMPLEMENTATION\"",
    with: "\"owner\":\"APP_SPECIFIC\""
  )
  #expect(ownerMismatchJson != validJson)
  #expect(throws: DecodingError.self) {
    try decoder.decode(DesignOSStoryDescriptor.self, from: Data(ownerMismatchJson.utf8))
  }

  // 3. Runtime deliverable ID mismatch: relationship has deliverable, but runtimeDeliverableID is null
  let runtimeMismatchJson = validJson.replacingOccurrences(
    of: "\"runtimeDeliverableID\":\"\(deliverableID)\"",
    with: "\"runtimeDeliverableID\":null"
  )
  #expect(runtimeMismatchJson != validJson)
  #expect(throws: DecodingError.self) {
    try decoder.decode(DesignOSStoryDescriptor.self, from: Data(runtimeMismatchJson.utf8))
  }

  // 4. Duplicate related IDs
  let firstRelatedID = original.relatedStoryIDs[0].rawValue
  let duplicateRelatedJson = validJson.replacingOccurrences(
    of: "\"relatedStoryIDs\":[\"\(firstRelatedID)\"",
    with: "\"relatedStoryIDs\":[\"\(firstRelatedID)\",\"\(firstRelatedID)\""
  )
  #expect(duplicateRelatedJson != validJson)
  #expect(throws: DesignOSStoryDescriptorError.invalidRelatedStoryIDs) {
    try decoder.decode(DesignOSStoryDescriptor.self, from: Data(duplicateRelatedJson.utf8))
  }

  // 5. Self-referential related ID
  let selfRelatedJson = validJson.replacingOccurrences(
    of: "\"relatedStoryIDs\":[",
    with: "\"relatedStoryIDs\":[\"\(original.id.rawValue)\","
  )
  #expect(selfRelatedJson != validJson)
  #expect(throws: DesignOSStoryDescriptorError.invalidRelatedStoryIDs) {
    try decoder.decode(DesignOSStoryDescriptor.self, from: Data(selfRelatedJson.utf8))
  }

  // 6. Combined invalid precedence: invalid relatedStoryIDs AND owner mismatch
  // Must throw invalidRelatedStoryIDs first rather than DecodingError
  let combinedInvalidJson = selfRelatedJson.replacingOccurrences(
    of: "\"owner\":\"RUNTIME_IMPLEMENTATION\"",
    with: "\"owner\":\"APP_SPECIFIC\""
  )
  #expect(combinedInvalidJson != selfRelatedJson)
  #expect(throws: DesignOSStoryDescriptorError.invalidRelatedStoryIDs) {
    try decoder.decode(DesignOSStoryDescriptor.self, from: Data(combinedInvalidJson.utf8))
  }
}
