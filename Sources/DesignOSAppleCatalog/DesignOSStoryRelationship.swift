/// The explicit boundary between canonical runtime stories and app-owned examples.
public enum DesignOSStoryRelationship: Equatable, Hashable, Sendable {
  /// The canonical executable story for one compiled runtime deliverable.
  case canonicalRuntimeStory(RuntimeDeliverableID)
  /// An app-owned example that uses zero or more compiled runtime deliverables.
  case appOwnedExample(usesRuntimeDeliverables: [RuntimeDeliverableID])

  /// The ownership boundary implied by this relationship.
  public var owner: DesignOSStoryOwner {
    switch self {
    case .canonicalRuntimeStory:
      .runtimeImplementation
    case .appOwnedExample:
      .appSpecific
    }
  }

  /// The canonical deliverable or the first runtime deliverable used by an app-owned example.
  public var runtimeDeliverableID: RuntimeDeliverableID? {
    switch self {
    case .canonicalRuntimeStory(let deliverableID):
      deliverableID
    case .appOwnedExample(let usesRuntimeDeliverables):
      usesRuntimeDeliverables.first
    }
  }

  /// Every runtime deliverable this story covers or demonstrates.
  public var usedRuntimeDeliverableIDs: [RuntimeDeliverableID] {
    switch self {
    case .canonicalRuntimeStory(let deliverableID):
      [deliverableID]
    case .appOwnedExample(let usesRuntimeDeliverables):
      usesRuntimeDeliverables
    }
  }
}

extension DesignOSStoryRelationship: Codable {
  private enum CodingKeys: String, CodingKey {
    case type
    case runtimeDeliverableID
    case usedRuntimeDeliverableIDs
  }

  private enum RelationshipType: String, Codable {
    case canonicalRuntimeStory = "CANONICAL_RUNTIME_STORY"
    case appOwnedExample = "APP_OWNED_EXAMPLE"
  }

  /// Decodes only one of the two closed relationship shapes.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(RelationshipType.self, forKey: .type)
    let runtimeDeliverableID = try container.decode(
      RuntimeDeliverableID?.self, forKey: .runtimeDeliverableID)
    let usedRuntimeDeliverableIDs = try container.decode(
      [RuntimeDeliverableID].self, forKey: .usedRuntimeDeliverableIDs)

    switch type {
    case .canonicalRuntimeStory:
      guard let runtimeDeliverableID, usedRuntimeDeliverableIDs.isEmpty else {
        throw DecodingError.dataCorruptedError(
          forKey: .type, in: container, debugDescription: "Invalid canonical story relationship.")
      }
      self = .canonicalRuntimeStory(runtimeDeliverableID)
    case .appOwnedExample:
      guard runtimeDeliverableID == nil,
        Set(usedRuntimeDeliverableIDs).count == usedRuntimeDeliverableIDs.count
      else {
        throw DecodingError.dataCorruptedError(
          forKey: .type, in: container, debugDescription: "Invalid app-owned story relationship.")
      }
      self = .appOwnedExample(usesRuntimeDeliverables: usedRuntimeDeliverableIDs)
    }
  }

  /// Encodes the closed relationship shape for the versioned bundle.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .canonicalRuntimeStory(let deliverableID):
      try container.encode(RelationshipType.canonicalRuntimeStory, forKey: .type)
      try container.encode(deliverableID, forKey: .runtimeDeliverableID)
      try container.encode([RuntimeDeliverableID](), forKey: .usedRuntimeDeliverableIDs)
    case .appOwnedExample(let usesRuntimeDeliverables):
      try container.encode(RelationshipType.appOwnedExample, forKey: .type)
      try container.encodeNil(forKey: .runtimeDeliverableID)
      try container.encode(usesRuntimeDeliverables, forKey: .usedRuntimeDeliverableIDs)
    }
  }
}
