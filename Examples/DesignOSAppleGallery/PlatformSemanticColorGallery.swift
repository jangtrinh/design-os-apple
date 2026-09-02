import DesignOSApple
import SwiftUI

struct PlatformSemanticColorGallery: View {
  @Environment(\.colorSchemeContrast) private var systemContrast
  @State private var appearance = PreviewAppearance.system

  var body: some View {
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
    .padding()
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
