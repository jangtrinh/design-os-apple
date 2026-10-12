import DesignOSApple
import SwiftUI

/// Isolated real controls for reference comparison; no secrets or network activity.
struct TextFieldSpecimen: View {
    @Environment(\.designOSAppStyle) private var style
    @State private var name = "Community lunch"
    @State private var biography = "Bring something you enjoy sharing."
    @State private var password = ""
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case name, biography, password }
    private let state = ProcessInfo.processInfo.environment["LAYERED_KIT_FIELD_STATE"] ?? "normal"
    private var isInvalid: Bool { state == "error" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                Text(state == "secure" ? "Private local input" : "Gathering name")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(style.palette.secondaryInk.color)
                    .padding(.horizontal, style.metrics.contentInset)
                if state == "secure" {
                    SecureField("Local sample password", text: $password)
                        .focused($focusedField, equals: .password)
                        .modifier(DesignOSAppTextFieldModifier())
                        .accessibilityIdentifier("fieldSecure")
                    Text(password.isEmpty ? "No text entered" : "Text entered")
                        .font(.caption)
                        .accessibilityIdentifier("fieldSecureStatus")
                } else if state == "multiline" {
                    TextField("Gathering details", text: $biography, axis: .vertical)
                        .lineLimit(3...6)
                        .focused($focusedField, equals: .biography)
                        .modifier(DesignOSAppTextFieldModifier(multiline: true))
                        .accessibilityIdentifier("fieldMultiline")
                } else if state == "nested" {
                    DesignOSAppSurface {
                        TextField("Gathering name", text: $name)
                            .focused($focusedField, equals: .name)
                            .modifier(DesignOSAppTextFieldModifier(cornerRadius:
                                DesignOSCornerGeometry.innerRadius(
                                    outerRadius: style.metrics.surfaceRadius,
                                    inset: style.metrics.contentInset)))
                            .accessibilityIdentifier("fieldNested")
                    }
                } else {
                    TextField("Gathering name", text: $name)
                        .focused($focusedField, equals: .name)
                        .modifier(DesignOSAppTextFieldModifier())
                        .disabled(state == "disabled")
                        .accessibilityHint(isInvalid ? "This gathering name is unavailable. Choose another name." : "")
                        .accessibilityIdentifier("fieldSingleLine")
                }
                if isInvalid {
                    Text("This gathering name is unavailable. Choose another name.")
                        .foregroundStyle(style.palette.dangerInk.color)
                        .font(.footnote)
                        .accessibilityIdentifier("fieldValidation")
                }
                Text("Local native input specimen · \(state)")
                    .font(.caption)
                    .foregroundStyle(style.palette.secondaryInk.color)
                Button("Finish editing") { focusedField = nil }
                    .buttonStyle(DesignOSSecondaryButtonStyle())
                    .accessibilityIdentifier("fieldFinishEditing")
            }
            .padding(style.metrics.pageInset)
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(style.palette.canvas.color)
    }
}
