import CryptoKit
import Foundation

/// Closed catalog-bundle encoding for people and automated evaluators.
public enum DesignOSStoryCatalogBundle {
  /// The only repository-relative publication path accepted by the bundle tool.
  public static let allowedRelativePath =
    "Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json"

  /// Produces canonical bytes for the typed release-candidate authority.
  public static func encoded() throws -> Data {
    let manifest = CatalogBundleManifest(
      deliverables: DesignOSRuntimeCatalog.deliverables.sorted { $0.id.rawValue < $1.id.rawValue },
      stories: DesignOSReleaseCatalog.stories.sorted { $0.id.rawValue < $1.id.rawValue }
    )
    let schema = CatalogBundleSchema()
    try validateManifest(manifest, against: schema)
    let manifestData = try canonicalData(manifest)
    let schemaData = try canonicalData(schema)
    let envelope = CatalogBundleEnvelope(
      bundleVersion: 2,
      manifest: manifest,
      manifestSHA256: digest(manifestData),
      schema: schema,
      schemaSHA256: digest(schemaData)
    )
    try validate(envelope)
    return try canonicalData(envelope)
  }

  /// Validates a published catalog envelope and returns canonical expected bytes.
  public static func validatedExpectedBytes(from data: Data) throws -> Data {
    let envelope: CatalogBundleEnvelope
    do {
      envelope = try JSONDecoder().decode(CatalogBundleEnvelope.self, from: data)
    } catch {
      throw BundleError.invalid
    }
    try validate(envelope)
    let expected = try encoded()
    guard data == expected else { throw BundleError.stale }
    return expected
  }

  private static func validate(_ envelope: CatalogBundleEnvelope) throws {
    guard envelope.bundleVersion == 2, envelope.schema == CatalogBundleSchema() else {
      throw BundleError.invalid
    }
    try validateManifest(envelope.manifest, against: envelope.schema)
    guard envelope.manifestSHA256 == digest(try canonicalData(envelope.manifest)),
      envelope.schemaSHA256 == digest(try canonicalData(envelope.schema))
    else { throw BundleError.invalid }
  }

  private static func validateManifest(
    _ manifest: CatalogBundleManifest,
    against schema: CatalogBundleSchema
  ) throws {
    let deliverableIDs = manifest.deliverables.map(\.id)
    let storyIDs = manifest.stories.map(\.id)
    guard deliverableIDs == deliverableIDs.sorted(by: { $0.rawValue < $1.rawValue }),
      Set(deliverableIDs).count == deliverableIDs.count,
      Set(deliverableIDs) == Set(RuntimeDeliverableID.allCases),
      storyIDs == storyIDs.sorted(by: { $0.rawValue < $1.rawValue }),
      Set(storyIDs).count == storyIDs.count,
      Set(storyIDs) == Set(DesignOSStoryID.currentExecutableCases),
      schema.runtimeDeliverableIDs == RuntimeDeliverableID.allCases,
      schema.storyIDs == DesignOSStoryID.currentExecutableCases
    else { throw BundleError.invalid }

    let deliverables = Dictionary(uniqueKeysWithValues: manifest.deliverables.map { ($0.id, $0) })
    let stories = Dictionary(uniqueKeysWithValues: manifest.stories.map { ($0.id, $0) })
    for deliverable in manifest.deliverables {
      guard deliverable.isComplete,
        let canonicalStoryID = deliverable.storyDisposition.storyID,
        let story = stories[canonicalStoryID],
        story.relationship == .canonicalRuntimeStory(deliverable.id),
        story.examplePath == deliverable.examplePath
      else { throw BundleError.invalid }
    }
    for story in manifest.stories {
      guard !story.title.isEmpty, !story.summary.isEmpty, !story.examplePath.isEmpty else {
        throw BundleError.invalid
      }
      switch story.relationship {
      case .canonicalRuntimeStory(let deliverableID):
        guard deliverables[deliverableID] != nil, story.owner == .runtimeImplementation else {
          throw BundleError.invalid
        }
      case .appOwnedExample(let usesRuntimeDeliverables):
        guard story.owner == .appSpecific,
          usesRuntimeDeliverables.allSatisfy({ deliverables[$0] != nil })
        else { throw BundleError.invalid }
      }
    }
  }

  private static func canonicalData<Value: Encodable>(_ value: Value) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    return try encoder.encode(value)
  }

  private static func digest(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }

  /// Stable errors for malformed or stale catalog-bundle bytes.
  public enum BundleError: Error, Equatable, Sendable { case invalid, stale }
}

extension RuntimeDeliverableDescriptor {
  fileprivate var isComplete: Bool {
    !module.isEmpty && !symbolOrNativeAPI.isEmpty && !platforms.isEmpty
      && Set(platforms).count == platforms.count
      && Set(minimumAvailability.map(\.platform)) == Set(platforms)
      && minimumAvailability.allSatisfy { $0.majorVersion > 0 }
      && !fallback.isEmpty && Set(customizationAxes).count == customizationAxes.count
      && !documentationPath.isEmpty && !examplePath.isEmpty && !verificationCommand.isEmpty
      && (storyDisposition.storyID != nil) != (storyDisposition.recipeOnlyReason != nil)
  }
}
