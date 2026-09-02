/// Stable lookup failures for the release catalog discovery contract.
public enum DesignOSStoryDiscoveryError: Error, Equatable, Sendable {
  /// No story matches the normalized exact query.
  case notFound
  /// More than one story matches at the active resolution level.
  case ambiguous
}

/// Fail-closed validation failures for release catalog membership and metadata.
public enum DesignOSReleaseCatalogError: Error, Equatable, Sendable {
  /// Story membership does not match the closed `DesignOSStoryID` set.
  case invalidStoryMembership
  /// A primary keyword or alias collides after normalization.
  case duplicateDiscoveryTerm
  /// A discovery term would shadow a stable story identity.
  case discoveryTermConflictsWithStoryID
  /// A related story is not admitted by the candidate catalog.
  case invalidRelatedStoryIDs
  /// A relationship does not match the story kind or runtime authority.
  case invalidRelationship
}

/// The complete typed story authority for the Gallery and generated release bundle.
public enum DesignOSReleaseCatalog {
  /// Every executable Gallery story in stable identity order.
  public static let stories: [DesignOSStoryDescriptor] = {
    let values =
      FoundationStoryRegistrations.values
      + ComponentAndPrimitiveStoryRegistrations.values
      + NativeRecipeStoryRegistrations.values
      + ExtensionAndDogfoodStoryRegistrations.extensionValues
      + ExtensionAndDogfoodStoryRegistrations.dogfoodValues
    do {
      try validate(values)
    } catch {
      preconditionFailure("Release story registrations must satisfy the closed discovery contract.")
    }
    return values
  }()

  /// Resolves one stable story from an exact ID, primary keyword, or alias.
  public static func resolve(_ term: String) throws -> DesignOSStoryDescriptor {
    try resolve(term, in: stories)
  }

  /// Resolves a query against candidate descriptors without fuzzy matching or fallback selection.
  public static func resolve(
    _ term: String,
    in candidateStories: [DesignOSStoryDescriptor]
  ) throws -> DesignOSStoryDescriptor {
    let normalizedTerm = DesignOSStoryDiscovery.normalize(term)
    if let id = DesignOSStoryID(rawValue: normalizedTerm) {
      let idMatches = candidateStories.filter { $0.id == id }
      if idMatches.count == 1 { return idMatches[0] }
      if idMatches.count > 1 { throw DesignOSStoryDiscoveryError.ambiguous }
      throw DesignOSStoryDiscoveryError.notFound
    }

    let primaryMatches = candidateStories.filter { $0.discovery.primaryKeyword == normalizedTerm }
    if primaryMatches.count == 1 { return primaryMatches[0] }
    if primaryMatches.count > 1 { throw DesignOSStoryDiscoveryError.ambiguous }

    let aliasMatches = candidateStories.filter { $0.discovery.aliases.contains(normalizedTerm) }
    if aliasMatches.count == 1 { return aliasMatches[0] }
    if aliasMatches.count > 1 { throw DesignOSStoryDiscoveryError.ambiguous }
    throw DesignOSStoryDiscoveryError.notFound
  }

  /// Validates closed membership, exact discovery terms, relationships, and related stories.
  public static func validate(_ candidateStories: [DesignOSStoryDescriptor]) throws {
    let candidateIDs = candidateStories.map(\.id)
    guard candidateIDs == DesignOSStoryID.currentExecutableCases,
      Set(candidateIDs).count == candidateIDs.count
    else { throw DesignOSReleaseCatalogError.invalidStoryMembership }

    let discoveryTerms = candidateStories.flatMap {
      [$0.discovery.primaryKeyword] + $0.discovery.aliases
    }
    guard Set(discoveryTerms).count == discoveryTerms.count else {
      throw DesignOSReleaseCatalogError.duplicateDiscoveryTerm
    }
    guard Set(discoveryTerms).isDisjoint(with: Set(DesignOSStoryID.allCases.map(\.rawValue))) else {
      throw DesignOSReleaseCatalogError.discoveryTermConflictsWithStoryID
    }

    let admittedIDs = Set(candidateIDs)
    for story in candidateStories {
      guard !story.relatedStoryIDs.isEmpty,
        !story.relatedStoryIDs.contains(story.id),
        Set(story.relatedStoryIDs).count == story.relatedStoryIDs.count,
        Set(story.relatedStoryIDs).isSubset(of: admittedIDs)
      else { throw DesignOSReleaseCatalogError.invalidRelatedStoryIDs }

      switch story.relationship {
      case .canonicalRuntimeStory(let deliverableID):
        guard story.kind != .productDemo,
          let deliverable = try? DesignOSRuntimeCatalog.deliverable(for: deliverableID),
          deliverable.storyDisposition.storyID == story.id,
          deliverable.examplePath == story.examplePath
        else { throw DesignOSReleaseCatalogError.invalidRelationship }
      case .appOwnedExample(let usesRuntimeDeliverables):
        guard story.kind == .productDemo,
          Set(usesRuntimeDeliverables).count == usesRuntimeDeliverables.count,
          usesRuntimeDeliverables.allSatisfy({
            (try? DesignOSRuntimeCatalog.deliverable(for: $0)) != nil
          })
        else { throw DesignOSReleaseCatalogError.invalidRelationship }
      }
    }
  }
}
