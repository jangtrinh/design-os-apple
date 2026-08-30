enum CatalogStoryRegistration {
  static func canonical(
    id: DesignOSStoryID,
    title: String,
    summary: String,
    deliverableID: RuntimeDeliverableID
  ) -> DesignOSStoryDescriptor {
    guard let deliverable = try? DesignOSRuntimeCatalog.deliverable(for: deliverableID),
      deliverable.storyDisposition.storyID == id
    else {
      preconditionFailure("Canonical story foreign keys must stay exact.")
    }
    return DesignOSStoryDescriptor(
      id: id,
      title: title,
      summary: summary,
      runtimeDeliverableID: deliverableID,
      examplePath: deliverable.examplePath
    )
  }

  static func dogfood(
    id: DesignOSStoryID,
    title: String,
    summary: String,
    deliverableID: RuntimeDeliverableID?,
    examplePath: String
  ) -> DesignOSStoryDescriptor {
    DesignOSStoryDescriptor(
      id: id,
      title: title,
      summary: summary,
      runtimeDeliverableID: deliverableID,
      examplePath: examplePath
    )
  }
}
