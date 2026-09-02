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
    ScrollView {
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
            ProfileCustomizationFactRow(fact: fact)
              .padding(.vertical, 7)
            if fact.id != selectedFacts.last?.id {
              Divider()
            }
          }
        }
        .font(DesignOSTypographyRole.callout.font)
      }
      .padding()
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

}

private struct ProfileCustomizationFactRow: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  let fact: ProfileFact

  @ViewBuilder
  var body: some View {
    if dynamicTypeSize.isAccessibilitySize {
      VStack(alignment: .leading, spacing: 4) {
        Text(fact.axis)
          .foregroundStyle(.secondary)
        Text(fact.value)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    } else {
      LabeledContent(fact.axis, value: fact.value)
    }
  }
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
