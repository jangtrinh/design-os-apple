import DesignOSApple
import SwiftUI

struct GalleryOverview: View {
  var body: some View {
    List {
      Section {
        LabeledContent("Figma identities", value: "569")
        LabeledContent("Component masters", value: "312")
        LabeledContent("Raw variants", value: "1,169")
      } header: {
        Text("Onboarded source")
      } footer: {
        Text("Every identity remains traceable; many map to one native recipe or semantic API.")
      }

      Section("Runtime now") {
        statusRow("Semantic color roles", value: "28", symbol: "paintpalette")
        statusRow("Typography roles", value: "11", symbol: "textformat")
        statusRow("Native call-site recipes", value: "14", symbol: "apple.logo")
        statusRow("Internal content primitives", value: "4", symbol: "square.stack.3d.up")
        statusRow(
          "Semantic content components",
          value: "2",
          symbol: "rectangle.3.group.bubble.left"
        )
      }

      Section("Native-first rule") {
        Label("Apple controls stay direct SwiftUI calls", systemImage: "checkmark.seal")
        Text("The package adds semantic content and composition only where SwiftUI has a real gap.")
          .foregroundStyle(DesignOSColorRole.labelSecondary.color)
          .font(DesignOSTypographyRole.callout.font)
      }
    }
  }

  private func statusRow(_ title: String, value: String, symbol: String) -> some View {
    LabeledContent {
      Text(value)
        .font(DesignOSTypographyRole.headline.font)
        .foregroundStyle(DesignOSColorRole.blue.color)
    } label: {
      Label(title, systemImage: symbol)
    }
  }
}
