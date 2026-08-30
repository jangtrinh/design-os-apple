import DesignOSApple
import SwiftUI

struct ProfileCustomizationGallery: View {
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
      VStack(alignment: .leading, spacing: 24) {
        profileSample("Default profile")
          .designOSProfile(.default)
        profileSample("Contrasting profile")
          .designOSProfile(contrastingProfile)
      }
      .padding()
      .frame(maxWidth: 720)
    }
  }

  private func profileSample(_ title: String) -> some View {
    ProfileCustomizationSample(title: title)
  }
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
        Text("Typography, spacing, radius, semantic color, surface, accessibility")
      } trailing: {
        Text("Live")
      }
    }
    .padding()
    .designOSCustomSurface()
  }
}
