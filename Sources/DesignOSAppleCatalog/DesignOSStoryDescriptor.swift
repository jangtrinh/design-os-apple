/// Fail-closed validation failures for descriptor-local relationship metadata.
public enum DesignOSStoryDescriptorError: Error, Equatable, Sendable {
  /// Related stories must not repeat the descriptor's identity or one another.
  case invalidRelatedStoryIDs
}

/// Immutable metadata for a candidate Gallery story.
public struct DesignOSStoryDescriptor: Codable, Equatable, Hashable, Sendable {
  /// The stable machine identifier.
  public let id: DesignOSStoryID
  /// The user-visible story title.
  public let title: String
  /// The bounded summary for catalog browsing.
  public let summary: String
  /// The teaching category for the story.
  public let kind: DesignOSStoryKind
  /// The exact human discovery contract.
  public let discovery: DesignOSStoryDiscovery
  /// The explicit runtime or app-owned boundary.
  public let relationship: DesignOSStoryRelationship
  /// Stable stories that provide useful next reading.
  public let relatedStoryIDs: [DesignOSStoryID]
  /// The repository-relative SwiftUI example that owns this exact route.
  public let examplePath: String

  /// The ownership boundary derived from the explicit relationship.
  public var owner: DesignOSStoryOwner { relationship.owner }

  /// Compatibility accessor for the canonical or first used runtime deliverable.
  public var runtimeDeliverableID: RuntimeDeliverableID? { relationship.runtimeDeliverableID }

  /// All runtime deliverables that this story covers or demonstrates.
  public var usedRuntimeDeliverableIDs: [RuntimeDeliverableID] {
    relationship.usedRuntimeDeliverableIDs
  }

  /// Creates immutable catalog metadata without views, closures, or host state.
  public init(
    id: DesignOSStoryID,
    title: String,
    summary: String,
    kind: DesignOSStoryKind,
    discovery: DesignOSStoryDiscovery,
    relationship: DesignOSStoryRelationship,
    relatedStoryIDs: [DesignOSStoryID],
    examplePath: String
  ) throws {
    guard !relatedStoryIDs.contains(id),
      Set(relatedStoryIDs).count == relatedStoryIDs.count
    else { throw DesignOSStoryDescriptorError.invalidRelatedStoryIDs }

    self.id = id
    self.title = title
    self.summary = summary
    self.kind = kind
    self.discovery = discovery
    self.relationship = relationship
    self.relatedStoryIDs = relatedStoryIDs
    self.examplePath = examplePath
  }

  /// Creates a deprecated compatibility descriptor from the pre-discovery contract.
  @available(*, deprecated, message: "Use the relationship and discovery initializer instead.")
  public init(
    id: DesignOSStoryID,
    title: String,
    summary: String,
    runtimeDeliverableID: RuntimeDeliverableID?,
    examplePath: String
  ) {
    self.id = id
    self.title = title
    self.summary = summary
    self.kind = runtimeDeliverableID == nil ? .productDemo : .nativeRecipe
    self.discovery = try! DesignOSStoryDiscovery(
      primaryKeyword: id.rawValue, aliases: [], intentQueries: ["legacy story compatibility"])
    self.relationship =
      runtimeDeliverableID.map(DesignOSStoryRelationship.canonicalRuntimeStory)
      ?? .appOwnedExample(usesRuntimeDeliverables: [])
    self.relatedStoryIDs = []
    self.examplePath = examplePath
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case examplePath
    case owner
    case runtimeDeliverableID
    case kind
    case discovery
    case relationship
    case relatedStoryIDs
    case summary
    case title
  }

  /// Decodes a descriptor only when compatibility fields match the relationship boundary.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(DesignOSStoryID.self, forKey: .id)
    let title = try container.decode(String.self, forKey: .title)
    let summary = try container.decode(String.self, forKey: .summary)
    let kind = try container.decode(DesignOSStoryKind.self, forKey: .kind)
    let discovery = try container.decode(DesignOSStoryDiscovery.self, forKey: .discovery)
    let relationship = try container.decode(DesignOSStoryRelationship.self, forKey: .relationship)
    let relatedStoryIDs = try container.decode([DesignOSStoryID].self, forKey: .relatedStoryIDs)
    let examplePath = try container.decode(String.self, forKey: .examplePath)
    let decodedOwner = try container.decode(DesignOSStoryOwner.self, forKey: .owner)
    let decodedRuntimeDeliverableID = try container.decode(
      RuntimeDeliverableID?.self, forKey: .runtimeDeliverableID)
    let descriptor = try Self(
      id: id, title: title, summary: summary, kind: kind, discovery: discovery,
      relationship: relationship, relatedStoryIDs: relatedStoryIDs, examplePath: examplePath)
    guard decodedOwner == descriptor.owner,
      decodedRuntimeDeliverableID == descriptor.runtimeDeliverableID
    else {
      throw DecodingError.dataCorruptedError(
        forKey: .relationship,
        in: container,
        debugDescription: "Story compatibility fields must match the relationship boundary."
      )
    }
    self = descriptor
  }

  /// Encodes relationship-derived compatibility fields as required bundle fields.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(examplePath, forKey: .examplePath)
    try container.encode(owner, forKey: .owner)
    try container.encode(runtimeDeliverableID, forKey: .runtimeDeliverableID)
    try container.encode(kind, forKey: .kind)
    try container.encode(discovery, forKey: .discovery)
    try container.encode(relationship, forKey: .relationship)
    try container.encode(relatedStoryIDs, forKey: .relatedStoryIDs)
    try container.encode(summary, forKey: .summary)
    try container.encode(title, forKey: .title)
  }
}
