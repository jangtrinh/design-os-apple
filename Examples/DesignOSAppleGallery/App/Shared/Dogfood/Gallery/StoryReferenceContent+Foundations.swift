import DesignOSAppleCatalog

extension StoryReferenceContent {
  static let foundationReferenceContent: [Self] = [
    .init(
      storyID: .profileCustomization,
      whatItIs:
        "Injects one coherent design-language profile into a SwiftUI subtree while native controls retain platform behavior.",
      useWhen:
        "A product needs coordinated typography, spacing, radius, semantic color, surface, and accessibility policy.",
      avoidWhen:
        "Only one local value changes; use the nearest semantic role or native modifier instead.",
      placement:
        "Apply `.designOSProfile(_:)` at the smallest shared container that should inherit the language.",
      contract: [
        .init(title: "App owns", detail: "Profile selection and product state."),
        .init(
          title: "Runtime owns", detail: "Package composition that reads the environment profile."),
        .init(title: "System owns", detail: "Dynamic Type and accessibility preferences."),
      ],
      code: """
        let base = DesignOSProfile.default
        let profile = DesignOSProfile(
          typography: .init(fontDesign: .expressive),
          spacing: base.spacing,
          radius: base.radius,
          semanticColors: .init(secondaryContent: .purple),
          surface: base.surface,
          accessibility: base.accessibility
        )

        ContentView()
          .designOSProfile(profile)
        """,
      preview: .destination
    ),
    .init(
      storyID: .colorRoles,
      whatItIs:
        "Names color by semantic intent so UIKit or AppKit can resolve appearance and contrast live.",
      useWhen:
        "Custom content needs a label, background, fill, separator, or status color that adapts with the platform.",
      avoidWhen:
        "A native hierarchical style such as `.secondary` already expresses the intended relationship.",
      placement:
        "Apply the role at the custom drawing or text boundary; never cache the resolved color value.",
      contract: [
        .init(title: "Intent", detail: "Apple Design OS stores the semantic role."),
        .init(
          title: "Resolution", detail: "UIKit or AppKit resolves current appearance and contrast."),
      ],
      code: """
        VStack(alignment: .leading) {
          Text("Primary content")
            .foregroundStyle(DesignOSColorRole.labelPrimary.color)
          Text("Supporting content")
            .foregroundStyle(DesignOSColorRole.labelSecondary.color)
        }
        """,
      preview: .destination
    ),
    .init(
      storyID: .platformSemanticColor,
      whatItIs:
        "Resolves the same semantic color role through the active Apple platform instead of substituting a literal color.",
      useWhen: "One public semantic role must behave correctly on iOS, iPadOS, and macOS.",
      avoidWhen:
        "The color carries brand artwork rather than interface meaning; use an asset with reviewed variants.",
      placement: "Resolve at render time in the view that consumes the role.",
      contract: [
        .init(
          title: "Appearance",
          detail: "Resolution follows light, dark, and increased-contrast environments."),
        .init(title: "Fallback", detail: "Use the nearest dynamic platform semantic role."),
      ],
      code: """
        Text("Adaptive label")
          .foregroundStyle(
            DesignOSColorRole.labelPrimary.color
          )
        """,
      preview: .bounded(.compact)
    ),
    .init(
      storyID: .typographyRoles,
      whatItIs:
        "Maps interface meaning to native text styles while preserving Dynamic Type and platform metrics.",
      useWhen:
        "Text has a stable semantic role such as title, headline, body, callout, or caption.",
      avoidWhen: "Matching a screenshot would require a fixed point size that breaks Dynamic Type.",
      placement:
        "Apply the role directly to each text element; use emphasis as a semantic variant.",
      contract: [
        .init(title: "Scale", detail: "Native text styles scale with the user setting."),
        .init(
          title: "Profile",
          detail: "A profile may change font design without replacing the semantic style."),
      ],
      code: """
        VStack(alignment: .leading) {
          Text("Section title")
            .font(DesignOSTypographyRole.title2.emphasized().font)
          Text("Supporting explanation")
            .font(DesignOSTypographyRole.body.font)
        }
        """,
      preview: .destination
    ),
    .init(
      storyID: .surfaceRoles,
      whatItIs:
        "Applies package-owned non-interactive surfaces with semantic fallback when translucency is unsuitable.",
      useWhen:
        "Custom content needs a branded container surface rather than a native control background.",
      avoidWhen: "A `List`, `Form`, sheet, toolbar, or native material already owns its surface.",
      placement: "Apply to the outer custom content container, never to every nested element.",
      contract: [
        .init(
          title: "Accessibility",
          detail: "Reduce Transparency can force an opaque semantic surface."),
        .init(
          title: "Interaction",
          detail: "The modifier does not add button, selection, or focus behavior."),
      ],
      code: """
        VStack(alignment: .leading) {
          Text("Custom summary")
          Text("Supporting details")
        }
        .padding()
        .designOSCustomSurface()
        """,
      preview: .destination
    ),
  ]
}
