import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Text field rounded surfaces reuse editorial radius and actual nested inset")
func textFieldCornerGeometry() {
  #expect(DesignOSAppTextFieldAppearance.minimumHeight == 48)
  let metrics = DesignOSAppStyle.editorial.metrics
  #expect(
    DesignOSAppTextFieldAppearance.radius(override: nil, surfaceRadius: metrics.surfaceRadius) == 24)
  let nested = DesignOSCornerGeometry.innerRadius(
    outerRadius: metrics.surfaceRadius, inset: metrics.contentInset)
  #expect(
    DesignOSAppTextFieldAppearance.radius(override: nested, surfaceRadius: metrics.surfaceRadius) == 8)
  for invalid in [CGFloat.nan, .infinity, -.infinity, -1] {
    #expect(
      DesignOSAppTextFieldAppearance.radius(override: invalid, surfaceRadius: metrics.surfaceRadius) == 0)
  }
}

@Test("Editorial field modifier composes with real native text and secure controls")
@MainActor
func appTextFieldCompositionsCompile() {
  let specimen = EditorialFieldCompileFixture().designOSAppStyle(.editorial)
  #expect(String(reflecting: type(of: specimen)).contains("ModifiedContent"))
}

private struct EditorialFieldCompileFixture: View {
  @Environment(\.designOSAppStyle) private var style
  @State private var text = "Local sample"
  @FocusState private var focused: Bool
  var body: some View {
    VStack {
      TextField("Name", text: $text)
        .focused($focused)
        .modifier(DesignOSAppTextFieldModifier())
        .onSubmit { focused = false }
      TextField("Description", text: $text, axis: .vertical)
        .lineLimit(3...6)
        .modifier(DesignOSAppTextFieldModifier(multiline: true))
      SecureField("Password", text: $text)
        .modifier(DesignOSAppTextFieldModifier())
      TextField("Disabled", text: $text)
        .modifier(DesignOSAppTextFieldModifier())
        .disabled(true)
      TextField("Invalid", text: $text)
        .modifier(DesignOSAppTextFieldModifier())
        .accessibilityHint("Choose another name.")
      Text("Choose another name.").foregroundStyle(style.palette.dangerInk.color)
    }
  }
}
