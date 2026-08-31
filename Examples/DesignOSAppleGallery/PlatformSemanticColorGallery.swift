import DesignOSApple
import SwiftUI

struct PlatformSemanticColorGallery: View {
  @Environment(\.colorSchemeContrast) private var systemContrast
  @State private var appearance = PreviewAppearance.system

  var body: some View {
    StorybookPage(
      storyID: "foundation.platform-semantic-color",
      summary:
        "See one semantic color contract re-resolve in a controlled preview. These controls simulate SwiftUI environment values; they are not physical-device evidence.",
      code: Self.code,
      guidance: [
        .init(
          title: "Use it when",
          detail:
            "Custom content needs adaptive labels, backgrounds, fills, separators, or status colors."
        ),
        .init(
          title: "Native owner",
          detail:
            "UIKit or AppKit supplies the dynamic color. Apple Design OS maps the semantic role and never publishes a literal value as the contract."
        ),
        .init(
          title: "Accessibility",
          detail:
            "Increased contrast is a live environment preview. Qualify the final hierarchy with system settings, VoiceOver, and the real container."
        ),
      ]
    ) {
      VStack(alignment: .leading, spacing: 16) {
        Picker("Appearance", selection: $appearance) {
          ForEach(PreviewAppearance.allCases) { option in
            Text(option.rawValue).tag(option)
          }
        }
        .pickerStyle(.segmented)

        LabeledContent("System contrast", value: contrastLabel)
          .font(DesignOSTypographyRole.callout.font)

        semanticPreview
          .preferredColorScheme(appearance.colorScheme)
      }
    }
  }

  private var contrastLabel: String {
    systemContrast == .increased ? "Increased" : "Standard"
  }

  private var semanticPreview: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Account summary")
        .font(DesignOSTypographyRole.title2.font)
        .foregroundStyle(DesignOSColorRole.labelPrimary.color)
      Text("Primary and supporting labels remain readable without storing resolved RGB values.")
        .foregroundStyle(DesignOSColorRole.labelSecondary.color)

      Divider()

      HStack(spacing: 12) {
        Label("Information", systemImage: "info.circle.fill")
          .foregroundStyle(DesignOSColorRole.blue.color)
        Label("Destructive", systemImage: "exclamationmark.triangle.fill")
          .foregroundStyle(DesignOSColorRole.red.color)
      }
      .font(DesignOSTypographyRole.callout.emphasized().font)
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(DesignOSColorRole.backgroundPrimary.color)
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .stroke(DesignOSColorRole.separator.color)
    }
    .clipShape(.rect(cornerRadius: 12))
    .accessibilityIdentifier("design-os.storybook.semantic-color.environment-preview")
  }

  private static let code = """
    import DesignOSApple
    import SwiftUI

    struct AdaptiveSummary: View {
      var body: some View {
        VStack(alignment: .leading) {
          Text("Account summary")
            .foregroundStyle(DesignOSColorRole.labelPrimary.color)
          Text("Supporting detail")
            .foregroundStyle(DesignOSColorRole.labelSecondary.color)
        }
        .background(DesignOSColorRole.backgroundPrimary.color)
      }
    }
    """
}

private enum PreviewAppearance: String, CaseIterable, Identifiable {
  case system = "System"
  case light = "Light"
  case dark = "Dark"

  var id: Self { self }

  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }
}
