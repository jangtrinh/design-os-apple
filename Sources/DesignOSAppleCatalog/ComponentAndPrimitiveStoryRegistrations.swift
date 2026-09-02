enum ComponentAndPrimitiveStoryRegistrations {
  static let values: [DesignOSStoryDescriptor] = [
    story(
      .listRow, "List row", "Caller-owned content inside native list rows.",
      "list row", ["list item"], ["build a list row"], [.sidebarRow, .accessorySlotLayout],
      .designOSListRow),
    story(
      .sidebarRow,
      "Sidebar row",
      "Caller-owned label and accessory content inside native sidebars.",
      "sidebar row", ["sidebar item"], ["build a sidebar row"], [.listRow, .sidebarToolbarContent],
      .designOSSidebarRow
    ),
    story(
      .accessorySlotLayout,
      "Accessory slot layout",
      "Package-internal arrangement for caller-owned row accessories.",
      "accessory slot", ["row accessory"], ["place a row accessory"],
      [.listRow, .sectionContentLayout],
      .accessorySlotLayout
    ),
    story(
      .sectionContentLayout,
      "Section content layout",
      "Package-internal title and trailing-content arrangement.",
      "section content", ["section layout"], ["arrange section content"],
      [.accessorySlotLayout, .listRow],
      .sectionContentLayout
    ),
    story(
      .sidebarToolbarContent,
      "Sidebar toolbar content",
      "Package-internal leading and trailing toolbar arrangement.",
      "sidebar toolbar", ["toolbar content"], ["arrange sidebar toolbar"],
      [.sidebarRow, .buttonAndToolbarActions],
      .sidebarToolbarContent
    ),
    story(
      .symbolContent,
      "Symbol content",
      "Package-internal caller-owned image geometry policies.",
      "symbol content", ["symbol layout"], ["place a symbol image"],
      [.listRow, .hierarchicalStyle],
      .symbolContent
    ),
  ]

  private static func story(
    _ id: DesignOSStoryID,
    _ title: String,
    _ summary: String,
    _ primaryKeyword: String,
    _ aliases: [String],
    _ intentQueries: [String],
    _ relatedStoryIDs: [DesignOSStoryID],
    _ deliverableID: RuntimeDeliverableID
  ) -> DesignOSStoryDescriptor {
    CatalogStoryRegistration.canonical(
      id: id, title: title, summary: summary,
      kind: id.rawValue.hasPrefix("component.") ? .semanticComponent : .primitive,
      primaryKeyword: primaryKeyword, aliases: aliases, intentQueries: intentQueries,
      relatedStoryIDs: relatedStoryIDs, deliverableID: deliverableID)
  }
}
