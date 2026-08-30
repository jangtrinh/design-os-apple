enum ComponentAndPrimitiveDeliverableRegistrations {
  static let values: [RuntimeDeliverableDescriptor] = [
    CatalogRegistrationDefaults.runtime(
      id: .designOSListRow,
      symbol: "DesignOSListRow",
      fallback: "Compose caller content directly in a native List row.",
      axes: [.spacing, .semanticColors],
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/Components/DesignOSListRow.md",
      examplePath: "Examples/DesignOSAppleGallery/Components/DesignOSListRowGallery.swift",
      storyID: .listRow
    ),
    CatalogRegistrationDefaults.runtime(
      id: .designOSSidebarRow,
      symbol: "DesignOSSidebarRow",
      fallback: "Compose caller content directly in a native sidebar row.",
      axes: [.spacing],
      documentationPath:
        "Sources/DesignOSApple/DesignOSApple.docc/Components/DesignOSSidebarRow.md",
      examplePath: "Examples/DesignOSAppleGallery/Components/DesignOSSidebarRowGallery.swift",
      storyID: .sidebarRow
    ),
    primitive(
      id: .accessorySlotLayout,
      symbol: "AccessorySlotLayout",
      documentation: "AccessorySlotLayout.md",
      example: "AccessorySlotLayoutGallery.swift",
      storyID: .accessorySlotLayout
    ),
    primitive(
      id: .sectionContentLayout,
      symbol: "SectionContentLayout",
      documentation: "SectionContentLayout.md",
      example: "SectionContentLayoutGallery.swift",
      storyID: .sectionContentLayout
    ),
    primitive(
      id: .sidebarToolbarContent,
      symbol: "SidebarToolbarContent",
      documentation: "SidebarToolbarContent.md",
      example: "SidebarToolbarContentGallery.swift",
      storyID: .sidebarToolbarContent
    ),
    primitive(
      id: .symbolContent,
      symbol: "SymbolContent",
      documentation: "SymbolContent.md",
      example: "SymbolContentGallery.swift",
      storyID: .symbolContent
    ),
  ]

  private static func primitive(
    id: RuntimeDeliverableID,
    symbol: String,
    documentation: String,
    example: String,
    storyID: DesignOSStoryID
  ) -> RuntimeDeliverableDescriptor {
    CatalogRegistrationDefaults.runtime(
      id: id,
      symbol: symbol,
      fallback: "The owning semantic component composes caller content directly.",
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/Primitives/\(documentation)",
      examplePath: "Examples/DesignOSAppleGallery/Primitives/\(example)",
      storyID: storyID,
      stateOwner: .runtime,
      accessibilityOwner: .runtime
    )
  }
}
