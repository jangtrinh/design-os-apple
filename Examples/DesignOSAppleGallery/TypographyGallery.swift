import DesignOSApple
import SwiftUI

struct TypographyGallery: View {
  @State private var previewSize = DynamicTypeSize.large

  private let roles: [TypographyRoleSample] = [
    .init("Large title", "largeTitle", "Top-level screen title", .largeTitle),
    .init("Title", "title", "Primary section title", .title),
    .init("Headline", "headline", "Emphasized short content", .headline),
    .init("Body", "body", "Long-form readable content", .body),
    .init(
      "Callout · emphasized", "callout.emphasized()", "Compact emphasis", .callout.emphasized()),
    .init("Footnote · italic", "footnote.italic()", "Supporting annotation", .footnote.italic()),
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Picker("Preview text size", selection: $previewSize) {
          Text("Default").tag(DynamicTypeSize.large)
          Text("AX 3").tag(DynamicTypeSize.accessibility3)
        }
        .pickerStyle(.segmented)

        VStack(alignment: .leading, spacing: 0) {
          ForEach(roles) { sample in
            VStack(alignment: .leading, spacing: 5) {
              Text(sample.name)
                .font(.caption)
                .foregroundStyle(DesignOSColorRole.labelSecondary.color)
              Text("The quick brown fox")
                .font(sample.role.font)
              Text("DesignOSTypographyRole.\(sample.symbol).font")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(DesignOSColorRole.labelSecondary.color)
              Text(sample.intent)
                .font(.caption)
            }
            .padding(.vertical, 12)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("design-os.storybook.typography.\(sample.id)")
            if sample.id != roles.last?.id {
              Divider()
            }
          }
        }
        .dynamicTypeSize(previewSize)
      }
      .padding()
    }
  }
}

private struct TypographyRoleSample: Identifiable {
  let name: String
  let symbol: String
  let intent: String
  let role: DesignOSTypographyRole

  init(_ name: String, _ symbol: String, _ intent: String, _ role: DesignOSTypographyRole) {
    self.name = name
    self.symbol = symbol
    self.intent = intent
    self.role = role
  }

  var id: String {
    symbol
      .replacingOccurrences(of: "largeTitle", with: "large-title")
      .replacingOccurrences(of: ".emphasized()", with: "-emphasized")
      .replacingOccurrences(of: ".italic()", with: "-italic")
  }
}
