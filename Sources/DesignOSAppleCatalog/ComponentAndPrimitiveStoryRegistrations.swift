enum ComponentAndPrimitiveStoryRegistrations {
  static let values: [DesignOSStoryDescriptor] = [
    story(.listRow, "List row", "Caller-owned content inside native list rows.", .designOSListRow),
    story(
      .sidebarRow,
      "Sidebar row",
      "Caller-owned label and accessory content inside native sidebars.",
      .designOSSidebarRow
    ),
    story(
      .accessorySlotLayout,
      "Accessory slot layout",
      "Package-internal arrangement for caller-owned row accessories.",
      .accessorySlotLayout
    ),
    story(
      .sectionContentLayout,
      "Section content layout",
      "Package-internal title and trailing-content arrangement.",
      .sectionContentLayout
    ),
    story(
      .sidebarToolbarContent,
      "Sidebar toolbar content",
      "Package-internal leading and trailing toolbar arrangement.",
      .sidebarToolbarContent
    ),
    story(
      .symbolContent,
      "Symbol content",
      "Package-internal caller-owned image geometry policies.",
      .symbolContent
    ),
  ]

  private static func story(
    _ id: DesignOSStoryID,
    _ title: String,
    _ summary: String,
    _ deliverableID: RuntimeDeliverableID
  ) -> DesignOSStoryDescriptor {
    CatalogStoryRegistration.canonical(
      id: id, title: title, summary: summary, deliverableID: deliverableID)
  }
}
