struct CatalogBundleEnvelope: Codable {
  let bundleVersion: Int
  let manifest: CatalogBundleManifest
  let manifestSHA256: String
  let schema: CatalogBundleSchema
  let schemaSHA256: String
}

struct CatalogBundleManifest: Codable {
  let deliverables: [RuntimeDeliverableDescriptor]
  let stories: [DesignOSStoryDescriptor]
}

struct CatalogBundleSchema: Codable, Equatable {
  let schemaVersion: Int
  let runtimeDeliverableIDs: [RuntimeDeliverableID]
  let storyIDs: [DesignOSStoryID]
  let envelope: CatalogObjectSchema
  let manifest: CatalogObjectSchema
  let runtimeDeliverable: CatalogObjectSchema
  let story: CatalogObjectSchema
  let storyDiscovery: CatalogObjectSchema
  let storyRelationship: CatalogObjectSchema
  let minimumAvailability: CatalogObjectSchema
  let storyDisposition: CatalogObjectSchema

  init() {
    schemaVersion = 2
    runtimeDeliverableIDs = RuntimeDeliverableID.allCases
    storyIDs = DesignOSStoryID.currentExecutableCases
    envelope = CatalogObjectSchema(
      required: ["bundleVersion", "manifest", "manifestSHA256", "schema", "schemaSHA256"],
      properties: [
        .init("bundleVersion", "integer"), .init("manifest", "object"),
        .init("manifestSHA256", "string"), .init("schema", "object"),
        .init("schemaSHA256", "string"),
      ]
    )
    manifest = CatalogObjectSchema(
      required: ["deliverables", "stories"],
      properties: [.init("deliverables", "array"), .init("stories", "array")]
    )
    runtimeDeliverable = CatalogObjectSchema(
      required: [
        "accessibilityOwner", "customizationAxes", "documentationPath", "examplePath",
        "fallback", "id", "minimumAvailability", "module", "platforms", "stateOwner",
        "storyDisposition", "symbolOrNativeAPI", "verificationCommand",
      ],
      properties: [
        .init("accessibilityOwner", "string"), .init("customizationAxes", "array"),
        .init("documentationPath", "string"), .init("examplePath", "string"),
        .init("fallback", "string"), .init("id", "string"),
        .init("minimumAvailability", "array"), .init("module", "string"),
        .init("platforms", "array"), .init("stateOwner", "string"),
        .init("storyDisposition", "object"), .init("symbolOrNativeAPI", "string"),
        .init("verificationCommand", "string"),
      ]
    )
    story = CatalogObjectSchema(
      required: [
        "discovery", "examplePath", "id", "kind", "owner", "relatedStoryIDs", "relationship",
        "runtimeDeliverableID", "summary", "title",
      ],
      properties: [
        .init("discovery", "object"), .init("examplePath", "string"), .init("id", "string"),
        .init("kind", "string"), .init("owner", "string"), .init("relatedStoryIDs", "array"),
        .init("relationship", "object"), .init("runtimeDeliverableID", "string|null"),
        .init("summary", "string"), .init("title", "string"),
      ]
    )
    storyDiscovery = CatalogObjectSchema(
      required: ["aliases", "intentQueries", "primaryKeyword"],
      properties: [
        .init("aliases", "array"), .init("intentQueries", "array"),
        .init("primaryKeyword", "string"),
      ]
    )
    storyRelationship = CatalogObjectSchema(
      required: ["runtimeDeliverableID", "type", "usedRuntimeDeliverableIDs"],
      properties: [
        .init("runtimeDeliverableID", "string|null"), .init("type", "string"),
        .init("usedRuntimeDeliverableIDs", "array"),
      ]
    )
    minimumAvailability = CatalogObjectSchema(
      required: ["majorVersion", "platform"],
      properties: [.init("majorVersion", "integer"), .init("platform", "string")]
    )
    storyDisposition = CatalogObjectSchema(
      required: ["recipeOnlyReason", "storyID"],
      properties: [.init("recipeOnlyReason", "string|null"), .init("storyID", "string|null")]
    )
  }
}

struct CatalogObjectSchema: Codable, Equatable {
  let additionalProperties: Bool
  let required: [String]
  let properties: [CatalogSchemaProperty]

  init(required: [String], properties: [CatalogSchemaProperty]) {
    additionalProperties = false
    self.required = required
    self.properties = properties
  }
}

struct CatalogSchemaProperty: Codable, Equatable {
  let name: String
  let type: String

  init(_ name: String, _ type: String) {
    self.name = name
    self.type = type
  }
}
