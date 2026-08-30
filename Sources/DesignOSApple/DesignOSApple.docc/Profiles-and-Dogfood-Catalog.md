# Profiles and Dogfood Catalog

Customize consumed design-language axes without replacing native SwiftUI behavior.

## Inject one profile

`DesignOSProfile` composes small immutable groups for the design-language axes that the
runtime implementation actually consumes. Inject one value at the product subtree boundary:

```swift
struct BrandedRoot: View {
  private let profile: DesignOSProfile = {
    do {
      return DesignOSProfile(
        typography: DesignOSTypographyProfile(fontDesign: .expressive),
        spacing: try DesignOSSpacingProfile(
          titleSubtitle: 4,
          sidebarContent: 10,
          listRowContent: 14
        ),
        radius: try DesignOSRadiusProfile(customContent: 18),
        semanticColors: DesignOSSemanticColorProfile(
          secondaryContent: .labelTertiary
        ),
        surface: DesignOSSurfaceProfile(role: .translucentContent),
        accessibility: .systemAdaptive
      )
    } catch {
      return .default
    }
  }()

  var body: some View {
    ProductContent()
      .designOSProfile(profile)
  }
}
```

Spacing and radius axes reject negative or non-finite values independently. Semantic colors
remain adaptive platform roles. ``DesignOSAccessibilityPolicy/systemAdaptive`` follows the
system; ``DesignOSAccessibilityPolicy/opaqueOnly`` may remove optional package translucency,
but it cannot re-enable an effect disabled by the system.

The scalar initializer remains a pre-release compatibility bridge. New code should prefer
the typed groups so each customization owner is explicit. A profile does not own app copy,
navigation, presentation, focus, window behavior, native control geometry, or system chrome.

## Browse exact stories

`DesignOSAppleCatalog` owns typed descriptors, runtime anchors, profile resolution, and
stable selector failures. The Gallery renderer maps admitted descriptors to synthetic
SwiftUI stories. Product pilot hosts may support a smaller set, but must fail visibly for
unsupported descriptors rather than render an empty ready state.

Use these launch arguments:

```text
--design-os-story <story-id>
--design-os-profile <profile-id>
```

The generated catalog bundle is accepted only when it byte-matches the compiled catalog.
Catalog admission means the route is technically available; it is not a claim of product
fidelity, asset rights, owner approval, or release readiness.
