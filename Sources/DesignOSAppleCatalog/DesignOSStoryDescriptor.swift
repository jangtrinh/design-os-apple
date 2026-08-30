/// Immutable metadata for a candidate pilot story.
public struct DesignOSStoryDescriptor: Codable, Equatable, Hashable, Sendable {
  /// The stable story identifier.
  public let id: DesignOSStoryID
  /// The user-visible story title.
  public let title: String
  /// The bounded summary for catalog browsing.
  public let summary: String
  /// The compiled runtime deliverable, or `nil` for app-owned controls.
  public let runtimeDeliverableID: RuntimeDeliverableID?
  /// The repository-relative SwiftUI example that owns this exact route.
  public let examplePath: String
  /// The ownership boundary derived solely from `runtimeDeliverableID`.
  public var owner: DesignOSStoryOwner {
    runtimeDeliverableID == nil ? .appSpecific : .runtimeImplementation
  }

  /// Creates immutable catalog metadata without views, closures, or host state.
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
    self.runtimeDeliverableID = runtimeDeliverableID
    self.examplePath = examplePath
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case examplePath
    case owner
    case runtimeDeliverableID
    case summary
    case title
  }

  /// Decodes a descriptor only when its serialized owner matches the derived boundary.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(DesignOSStoryID.self, forKey: .id)
    let title = try container.decode(String.self, forKey: .title)
    let summary = try container.decode(String.self, forKey: .summary)
    let runtimeDeliverableID = try container.decode(
      RuntimeDeliverableID?.self, forKey: .runtimeDeliverableID)
    let examplePath = try container.decode(String.self, forKey: .examplePath)
    let decodedOwner = try container.decode(DesignOSStoryOwner.self, forKey: .owner)
    let descriptor = Self(
      id: id,
      title: title,
      summary: summary,
      runtimeDeliverableID: runtimeDeliverableID,
      examplePath: examplePath
    )
    guard decodedOwner == descriptor.owner else {
      throw DecodingError.dataCorruptedError(
        forKey: .owner,
        in: container,
        debugDescription: "Story owner must match runtime deliverable ownership."
      )
    }
    self = descriptor
  }

  /// Encodes the derived owner as a required closed-bundle field.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(examplePath, forKey: .examplePath)
    try container.encode(owner, forKey: .owner)
    try container.encode(runtimeDeliverableID, forKey: .runtimeDeliverableID)
    try container.encode(summary, forKey: .summary)
    try container.encode(title, forKey: .title)
  }
}
