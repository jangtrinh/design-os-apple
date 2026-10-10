/// The strongest repository example available for a native API.
///
/// These dispositions describe source coverage, not a claim that a device,
/// accessibility, or current-SDK validation gate has passed.
public enum DesignOSNativeCapabilityCoverage: String, CaseIterable, Sendable {
  /// A Gallery view contains the real native call.
  case nativeSpecimen
  /// A test fixture contains the call, but its Gallery route does not demonstrate it.
  case compileFixture
  /// Guidance exists without a corresponding native call in the registered example.
  case documentationOnly
  /// A fixture exists, but execution requires a separate app or extension host.
  case hostIntegrationRequired
}

/// A native API lookup result linked to the existing typed release authority.
///
/// This is a retrieval aid, not a package-owned control or an additional release
/// deliverable. Consumers call the Apple API directly and inspect `coverage` before
/// treating its source example as an interactive specimen.
public struct DesignOSNativeCapability: Equatable, Sendable {
  /// Framework-qualified native API identity, for example `SwiftUI.DatePicker`.
  public var id: String { "\(framework).\(nativeAPI)" }
  /// Apple framework that owns the API.
  public let framework: String
  /// Exact API spelling, without a signature or generic arguments.
  public let nativeAPI: String
  /// Additional exact, case-insensitive retrieval terms.
  public let aliases: [String]
  /// Strongest source coverage in this repository.
  public let coverage: DesignOSNativeCapabilityCoverage
  /// Repository-relative file containing the native call or documentation.
  public let evidencePath: String
  /// API-specific platform limits within this package's supported floors.
  public let minimumAvailability: [DesignOSMinimumAvailability]
  /// The existing runtime deliverable; no independent registration is created.
  public let deliverable: RuntimeDeliverableDescriptor
  /// The existing story. A route may only explain host integration; see `coverage`.
  public let story: DesignOSStoryDescriptor

  /// Platforms supported by this specific example, not every API in its recipe family.
  public var platforms: [DesignOSPlatform] { minimumAvailability.map(\.platform) }

  /// Documentation inherited from the runtime authority.
  public var documentationPath: String { deliverable.documentationPath }

  internal var lookupTerms: [String] {
    ([nativeAPI, id] + aliases).map(DesignOSStoryDiscovery.normalize)
  }

  internal init(
    nativeAPI: String,
    framework: String = "SwiftUI",
    aliases: [String] = [],
    deliverableID: RuntimeDeliverableID,
    coverage: DesignOSNativeCapabilityCoverage = .nativeSpecimen,
    evidencePath: String? = nil,
    minimumAvailability: [DesignOSMinimumAvailability]? = nil
  ) {
    guard let deliverable = DesignOSRuntimeCatalog.deliverables.first(where: {
      $0.id == deliverableID
    }), let storyID = deliverable.storyDisposition.storyID,
      let story = DesignOSReleaseCatalog.stories.first(where: { $0.id == storyID })
    else {
      preconditionFailure("Native API coverage must reference an existing canonical story.")
    }
    self.nativeAPI = nativeAPI
    self.framework = framework
    self.aliases = aliases
    self.coverage = coverage
    self.deliverable = deliverable
    self.story = story
    self.evidencePath = evidencePath ?? deliverable.examplePath
    self.minimumAvailability = minimumAvailability ?? deliverable.minimumAvailability
  }
}
