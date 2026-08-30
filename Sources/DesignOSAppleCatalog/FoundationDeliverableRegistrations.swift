enum FoundationDeliverableRegistrations {
  static let values: [RuntimeDeliverableDescriptor] = [
    CatalogRegistrationDefaults.runtime(
      id: .designOSProfile,
      symbol: "DesignOSProfile / View.designOSProfile(_:)",
      fallback: "DesignOSProfile.default preserves the package defaults.",
      axes: DesignOSCustomizationAxis.allCases,
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/Profiles-and-Dogfood-Catalog.md",
      examplePath: "Examples/DesignOSAppleGallery/ProfileCustomizationGallery.swift",
      storyID: .profileCustomization,
      accessibilityOwner: .runtime
    ),
    CatalogRegistrationDefaults.runtime(
      id: .designOSColorRole,
      symbol: "DesignOSColorRole",
      fallback: "Use the nearest dynamic platform semantic role.",
      axes: [.semanticColors],
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/Color-Roles.md",
      examplePath: "Examples/DesignOSAppleGallery/ColorRolesGallery.swift",
      storyID: .colorRoles
    ),
    CatalogRegistrationDefaults.runtime(
      id: .platformSemanticColor,
      symbol: "DesignOSColorRole.color",
      fallback: "Resolve the same semantic role on the active platform.",
      axes: [.semanticColors, .accessibility],
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/Platform-Semantic-Color.md",
      examplePath: "Examples/DesignOSAppleGallery/PlatformSemanticColorGallery.swift",
      storyID: .platformSemanticColor
    ),
    CatalogRegistrationDefaults.runtime(
      id: .designOSTypographyRole,
      symbol: "DesignOSTypographyRole.font(profile:)",
      fallback: "Preserve the native semantic text style and Dynamic Type scaling.",
      axes: [.typography],
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/Typography.md",
      examplePath: "Examples/DesignOSAppleGallery/TypographyGallery.swift",
      storyID: .typographyRoles
    ),
    CatalogRegistrationDefaults.runtime(
      id: .designOSSurfaceRole,
      symbol: "DesignOSSurfaceRole / View.designOSCustomSurface()",
      fallback: "Use an opaque semantic background when translucency is unavailable.",
      axes: [.radius, .surface, .accessibility],
      documentationPath: "Sources/DesignOSApple/DesignOSApple.docc/Surface-Roles.md",
      examplePath: "Examples/DesignOSAppleGallery/DesignOSSurfaceRoleGallery.swift",
      storyID: .surfaceRoles,
      accessibilityOwner: .runtime
    ),
  ]
}
