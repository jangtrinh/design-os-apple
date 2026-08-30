enum FoundationStoryRegistrations {
  static let values: [DesignOSStoryDescriptor] = [
    story(
      .profileCustomization,
      "Profile customization",
      "Typed typography, spacing, radius, color, surface, and accessibility axes.",
      .designOSProfile
    ),
    story(
      .colorRoles,
      "Color roles",
      "Adaptive semantic color intent without literal replacements.",
      .designOSColorRole
    ),
    story(
      .platformSemanticColor,
      "Platform semantic color",
      "Live platform resolution across appearance and contrast changes.",
      .platformSemanticColor
    ),
    story(
      .typographyRoles,
      "Typography roles",
      "Semantic native text styles that preserve Dynamic Type.",
      .designOSTypographyRole
    ),
    story(
      .surfaceRoles,
      "Surface roles",
      "Custom non-interactive surfaces with opaque accessibility fallback.",
      .designOSSurfaceRole
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
