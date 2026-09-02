enum CatalogStoryRegistration {
  static func canonical(
    id: DesignOSStoryID,
    title: String,
    summary: String,
    kind: DesignOSStoryKind,
    primaryKeyword: String,
    aliases: [String],
    intentQueries: [String],
    relatedStoryIDs: [DesignOSStoryID],
    deliverableID: RuntimeDeliverableID
  ) -> DesignOSStoryDescriptor {
    guard let deliverable = try? DesignOSRuntimeCatalog.deliverable(for: deliverableID),
      deliverable.storyDisposition.storyID == id
    else {
      preconditionFailure("Canonical story foreign keys must stay exact.")
    }
    return descriptor(
      id: id, title: title, summary: summary, kind: kind, primaryKeyword: primaryKeyword,
      aliases: aliases, intentQueries: intentQueries,
      relationship: .canonicalRuntimeStory(deliverableID), relatedStoryIDs: relatedStoryIDs,
      examplePath: deliverable.examplePath)
  }

  static func dogfood(
    id: DesignOSStoryID,
    title: String,
    summary: String,
    primaryKeyword: String,
    aliases: [String],
    intentQueries: [String],
    relatedStoryIDs: [DesignOSStoryID],
    usesDeliverableIDs: [RuntimeDeliverableID],
    examplePath: String
  ) -> DesignOSStoryDescriptor {
    descriptor(
      id: id, title: title, summary: summary, kind: .productDemo,
      primaryKeyword: primaryKeyword, aliases: aliases, intentQueries: intentQueries,
      relationship: .appOwnedExample(usesRuntimeDeliverables: usesDeliverableIDs),
      relatedStoryIDs: relatedStoryIDs, examplePath: examplePath)
  }

  private static func descriptor(
    id: DesignOSStoryID,
    title: String,
    summary: String,
    kind: DesignOSStoryKind,
    primaryKeyword: String,
    aliases: [String],
    intentQueries: [String],
    relationship: DesignOSStoryRelationship,
    relatedStoryIDs: [DesignOSStoryID],
    examplePath: String
  ) -> DesignOSStoryDescriptor {
    do {
      return try DesignOSStoryDescriptor(
        id: id, title: title, summary: summary, kind: kind,
        discovery: DesignOSStoryDiscovery(
          primaryKeyword: primaryKeyword, aliases: aliases, intentQueries: intentQueries),
        relationship: relationship, relatedStoryIDs: relatedStoryIDs, examplePath: examplePath)
    } catch {
      preconditionFailure("Story registrations must contain valid discovery metadata.")
    }
  }
}
