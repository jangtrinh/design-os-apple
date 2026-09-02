import DesignOSAppleCatalog

extension DesignOSStoryDescriptor {
  var galleryKindLabel: String {
    switch kind {
    case .foundation: "Foundation"
    case .semanticComponent: "Component"
    case .primitive: "Internal primitive"
    case .nativeRecipe: "Native recipe"
    case .extensionRecipe: "Extension recipe"
    case .productDemo: "Product example"
    }
  }

  var galleryOwnershipLabel: String {
    switch owner {
    case .runtimeImplementation: "Runtime"
    case .appSpecific: "App-owned"
    }
  }

  var galleryPlatformFacts: [StoryReferenceFact] {
    let deliverables = usedRuntimeDeliverableIDs.compactMap {
      try? DesignOSRuntimeCatalog.deliverable(for: $0)
    }
    guard !deliverables.isEmpty else {
      return [.init(title: "Runtime", detail: "Unavailable; Gallery-only app fixture.")]
    }

    let platforms = Set(deliverables.flatMap(\.platforms)).sorted { $0.rawValue < $1.rawValue }
    let availability = deliverables.flatMap(\.minimumAvailability)
    let availabilityText =
      availability
      .reduce(into: [DesignOSPlatform: Int]()) { result, item in
        result[item.platform] = min(result[item.platform] ?? item.majorVersion, item.majorVersion)
      }
      .sorted { $0.key.rawValue < $1.key.rawValue }
      .map { "\($0.key.rawValue) \($0.value)+" }
      .joined(separator: ", ")

    var facts = [
      StoryReferenceFact(
        title: "Platforms", detail: platforms.map(\.rawValue).joined(separator: ", ")),
      StoryReferenceFact(title: "Runtime availability", detail: availabilityText),
    ]
    if deliverables.count == 1, let fallback = deliverables.first?.fallback {
      facts.append(.init(title: "Runtime fallback", detail: fallback))
    } else {
      facts.append(
        .init(
          title: "Uses runtime",
          detail: usedRuntimeDeliverableIDs.map(\.rawValue).joined(separator: ", ")
        ))
    }
    return facts
  }

  var galleryRelatedStories: [DesignOSStoryDescriptor] {
    relatedStoryIDs.compactMap { relatedID in
      DesignOSReleaseCatalog.stories.first(where: { $0.id == relatedID })
    }
  }
}
