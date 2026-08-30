import DesignOSApple
import SwiftUI

struct OmniActHUDAutocompleteMaterialStory: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.designOSProfile) private var profile
  @State private var query = ""

  private var surfacePath: OmniActHUDSurfacePath {
    OmniActHUDSurfaceResolver.path(
      profile: profile,
      reduceTransparency: reduceTransparency
    )
  }

  var body: some View {
    ZStack {
      surfaceBackground
      VStack(alignment: .leading, spacing: 12) {
        Text("Ask OmniAct")
          .font(.headline)
        TextField("Describe the result you need", text: $query)
          .textFieldStyle(.roundedBorder)
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(OmniActHUDStoryFixtures.suggestions) { suggestion in
              Button {
              } label: {
                VStack(alignment: .leading, spacing: 2) {
                  Text(suggestion.title)
                  Text(suggestion.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
              }
              .buttonStyle(.plain)
            }
          }
        }
        .frame(maxHeight: 160)
      }
      .padding(20)
    }
    .clipShape(
      RoundedRectangle(
        cornerRadius: profile.customContentCornerRadius,
        style: .continuous
      )
    )
    .padding()
    .accessibilityIdentifier("design-os.gallery.omniact-hud.\(surfacePath.accessibilityName)")
  }

  @ViewBuilder private var surfaceBackground: some View {
    switch surfacePath {
    case .nativeMaterial:
      RoundedRectangle(cornerRadius: profile.customContentCornerRadius, style: .continuous)
        .fill(.regularMaterial)
    case .opaqueBackground:
      RoundedRectangle(cornerRadius: profile.customContentCornerRadius, style: .continuous)
        .fill(DesignOSColorRole.backgroundPrimary.color)
    }
  }
}

extension OmniActHUDSurfacePath {
  fileprivate var accessibilityName: String {
    switch self {
    case .nativeMaterial: "native-material"
    case .opaqueBackground: "opaque-background"
    }
  }
}
