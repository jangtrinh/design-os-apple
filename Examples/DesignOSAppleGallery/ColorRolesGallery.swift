import DesignOSApple
import SwiftUI

struct ColorRolesGallery: View {
  private let roles: [ColorRoleSample] = [
    .init("Primary label", "labelPrimary", "Main text", .labelPrimary),
    .init("Secondary label", "labelSecondary", "Supporting text", .labelSecondary),
    .init("Primary background", "backgroundPrimary", "Base canvas", .backgroundPrimary),
    .init("Primary fill", "fillPrimary", "Control fill", .fillPrimary),
    .init("Separator", "separator", "Content boundary", .separator),
    .init("Blue", "blue", "Informational action", .blue),
    .init("Green", "green", "Success status", .green),
    .init("Orange", "orange", "Caution status", .orange),
    .init("Red", "red", "Destructive status", .red),
  ]

  var body: some View {
    StorybookPage(
      storyID: "foundation.color-roles",
      summary:
        "Choose a semantic intent first. UIKit or AppKit resolves the actual color for the active appearance and accessibility settings.",
      code: Self.code,
      guidance: [
        .init(
          title: "Use it when",
          detail: "Styling custom content that cannot use a native hierarchical style directly."),
        .init(
          title: "Native owner",
          detail:
            "UIKit and AppKit resolve appearance and contrast. The design system stores semantic intent, never a cached RGB value."
        ),
        .init(
          title: "Accessibility",
          detail:
            "Role names and status text carry meaning without relying on color alone. Verify contrast in the real container."
        ),
      ]
    ) {
      VStack(spacing: 0) {
        ForEach(roles) { sample in
          HStack(spacing: 14) {
            Circle()
              .fill(sample.role.color)
              .frame(width: 36, height: 36)
              .overlay(Circle().stroke(DesignOSColorRole.separator.color))
              .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
              Text(sample.name)
                .font(DesignOSTypographyRole.headline.font)
              Text(sample.intent)
                .foregroundStyle(DesignOSColorRole.labelSecondary.color)
              Text("DesignOSColorRole.\(sample.symbol)")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(DesignOSColorRole.labelSecondary.color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .padding(.vertical, 10)
          .accessibilityElement(children: .combine)
          .accessibilityIdentifier("design-os.storybook.color-role.\(sample.id)")
          if sample.id != roles.last?.id {
            Divider()
          }
        }
      }
    }
  }

  private static let code = """
    import DesignOSApple
    import SwiftUI

    struct SemanticLabels: View {
      var body: some View {
        VStack(alignment: .leading) {
          Text("Primary content")
            .foregroundStyle(DesignOSColorRole.labelPrimary.color)
          Text("Supporting content")
            .foregroundStyle(DesignOSColorRole.labelSecondary.color)
        }
      }
    }
    """
}

private struct ColorRoleSample: Identifiable {
  let name: String
  let symbol: String
  let intent: String
  let role: DesignOSColorRole

  init(_ name: String, _ symbol: String, _ intent: String, _ role: DesignOSColorRole) {
    self.name = name
    self.symbol = symbol
    self.intent = intent
    self.role = role
  }

  var id: String {
    symbol.replacingOccurrences(of: "Primary", with: "-primary").replacingOccurrences(
      of: "Secondary", with: "-secondary"
    ).lowercased()
  }
}
