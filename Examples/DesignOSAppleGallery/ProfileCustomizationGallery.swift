import DesignOSApple
import SwiftUI

struct ProfileCustomizationGallery: View {
  @State private var selection = ProfileOption.defaultProfile

  private let contrastingProfile = DesignOSProfile(
    typography: DesignOSTypographyProfile(fontDesign: .expressive),
    spacing: try! DesignOSSpacingProfile(
      titleSubtitle: 6,
      sidebarContent: 14,
      listRowContent: 18
    ),
    radius: try! DesignOSRadiusProfile(customContent: 24),
    semanticColors: DesignOSSemanticColorProfile(secondaryContent: .purple),
    surface: DesignOSSurfaceProfile(role: .translucentContent),
    accessibility: .opaqueOnly
  )

  var body: some View {
    StorybookPage(
      storyID: "foundation.profile-customization",
      summary:
        "Switch the same component between typed design-language profiles. Native behavior stays intact while package-owned typography, spacing, radius, color, surface, and accessibility policy change together.",
      code: Self.code,
      guidance: [
        .init(
          title: "Use it when",
          detail:
            "A product needs a coherent design language injected into a SwiftUI subtree without replacing native controls."
        ),
        .init(
          title: "Ownership",
          detail:
            "The app owns profile selection. Apple Design OS owns package composition. SwiftUI and system accessibility settings remain authoritative."
        ),
        .init(
          title: "Accessibility",
          detail:
            "A profile may constrain optional package translucency, but never overrides Reduce Transparency or other system preferences."
        ),
      ]
    ) {
      VStack(alignment: .leading, spacing: 16) {
        Picker("Profile", selection: $selection) {
          ForEach(ProfileOption.allCases) { option in
            Text(option.label).tag(option)
          }
        }
        .pickerStyle(.segmented)

        ProfileCustomizationSample(title: selection.label)
          .designOSProfile(selectedProfile)

        VStack(spacing: 0) {
          ForEach(selectedFacts) { fact in
            LabeledContent(fact.axis, value: fact.value)
              .padding(.vertical, 7)
            if fact.id != selectedFacts.last?.id {
              Divider()
            }
          }
        }
        .font(DesignOSTypographyRole.callout.font)
      }
    }
  }

  private var selectedProfile: DesignOSProfile {
    selection == .defaultProfile ? .default : contrastingProfile
  }

  private var selectedFacts: [ProfileFact] {
    switch selection {
    case .defaultProfile:
      [
        .init("Typography", "standard"), .init("Spacing", "2 / 8 / 12 pt"),
        .init("Radius", "12 pt"), .init("Secondary color", "labelSecondary"),
        .init("Surface", "content"), .init("Accessibility", "systemAdaptive"),
      ]
    case .contrasting:
      [
        .init("Typography", "expressive"), .init("Spacing", "6 / 14 / 18 pt"),
        .init("Radius", "24 pt"), .init("Secondary color", "purple"),
        .init("Surface", "translucentContent"), .init("Accessibility", "opaqueOnly"),
      ]
    }
  }

  private static let code = """
    import DesignOSApple
    import SwiftUI

    struct BrandedRoot: View {
      private let profile: DesignOSProfile = {
        do {
          return DesignOSProfile(
            typography: DesignOSTypographyProfile(fontDesign: .expressive),
            spacing: try DesignOSSpacingProfile(
              titleSubtitle: 6,
              sidebarContent: 14,
              listRowContent: 18
            ),
            radius: try DesignOSRadiusProfile(customContent: 24),
            semanticColors: DesignOSSemanticColorProfile(secondaryContent: .purple),
            surface: DesignOSSurfaceProfile(role: .translucentContent),
            accessibility: .opaqueOnly
          )
        } catch {
          return .default
        }
      }()

      var body: some View {
        ContentView()
          .designOSProfile(profile)
      }
    }
    """
}

private enum ProfileOption: String, CaseIterable, Identifiable {
  case defaultProfile
  case contrasting

  var id: Self { self }
  var label: String { self == .defaultProfile ? "Default" : "Contrasting" }
}

private struct ProfileFact: Identifiable {
  let axis: String
  let value: String

  init(_ axis: String, _ value: String) {
    self.axis = axis
    self.value = value
  }

  var id: String { axis }
}

private struct ProfileCustomizationSample: View {
  @Environment(\.designOSProfile) private var profile

  let title: String

  var body: some View {
    VStack(alignment: .leading, spacing: profile.spacing.titleSubtitle) {
      Text(title)
        .font(DesignOSTypographyRole.title2.font(profile: profile))
      DesignOSListRow {
        Image(systemName: "slider.horizontal.3")
          .accessibilityHidden(true)
      } title: {
        Text("Typed design-language axes")
      } subtitle: {
        Text("This specimen reads the selected environment profile live.")
      } trailing: {
        Text("Live")
      }
    }
    .padding()
    .designOSCustomSurface()
  }
}
