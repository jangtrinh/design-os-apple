enum FoundationStoryRegistrations {
  static let values: [DesignOSStoryDescriptor] = [
    story(
      .profileCustomization,
      "Profile customization",
      "Typed typography, spacing, radius, color, surface, and accessibility axes.",
      "profile customization", ["design profile"], ["configure a design profile"],
      [.typographyRoles, .surfaceRoles],
      .designOSProfile
    ),
    story(
      .colorRoles,
      "Color roles",
      "Adaptive semantic color intent without literal replacements.",
      "color roles", ["semantic colors"], ["choose semantic colors"],
      [.platformSemanticColor, .surfaceRoles],
      .designOSColorRole
    ),
    story(
      .platformSemanticColor,
      "Platform semantic color",
      "Live platform resolution across appearance and contrast changes.",
      "platform color", ["adaptive color"], ["resolve platform colors"],
      [.colorRoles, .surfaceRoles],
      .platformSemanticColor
    ),
    story(
      .typographyRoles,
      "Typography roles",
      "Semantic native text styles that preserve Dynamic Type.",
      "typography roles", ["text styles"], ["use dynamic type text"],
      [.profileCustomization, .contentUnavailable],
      .designOSTypographyRole
    ),
    story(
      .surfaceRoles,
      "Surface roles",
      "Custom non-interactive surfaces with opaque accessibility fallback.",
      "surface roles", ["semantic surface"], ["style a content surface"],
      [.colorRoles, .materialAndGlassSurface],
      .designOSSurfaceRole
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
      id: id, title: title, summary: summary, kind: .foundation,
      primaryKeyword: primaryKeyword, aliases: aliases, intentQueries: intentQueries,
      relatedStoryIDs: relatedStoryIDs, deliverableID: deliverableID)
  }
}
