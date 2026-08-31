import DesignOSApple
import SwiftUI

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

struct StorybookPage<Preview: View>: View {
  let storyID: String
  let summary: String
  let code: String
  let guidance: [StorybookGuidance]
  @ViewBuilder let preview: () -> Preview

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        Text(summary)
          .font(DesignOSTypographyRole.body.font)
          .foregroundStyle(DesignOSColorRole.labelSecondary.color)

        section(
          "Live preview",
          systemImage: "play.rectangle.fill",
          identifier: "design-os.storybook.\(storyID).preview"
        ) {
          preview()
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        section(
          "SwiftUI code",
          systemImage: "chevron.left.forwardslash.chevron.right",
          identifier: "design-os.storybook.\(storyID).code"
        ) {
          StorybookCodeBlock(storyID: storyID, code: code)
        }

        section(
          "Usage & ownership",
          systemImage: "info.circle.fill",
          identifier: "design-os.storybook.\(storyID).guidance"
        ) {
          VStack(alignment: .leading, spacing: 18) {
            ForEach(guidance) { item in
              VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                  .font(DesignOSTypographyRole.headline.font)
                Text(item.detail)
                  .font(DesignOSTypographyRole.body.font)
                  .foregroundStyle(DesignOSColorRole.labelSecondary.color)
                  .accessibilityIdentifier(
                    "design-os.storybook.\(storyID).guidance.\(item.accessibilityID)"
                  )
              }
            }
          }
        }
      }
      .padding(.vertical, 20)
      .frame(maxWidth: 720, alignment: .leading)
      .frame(maxWidth: .infinity, alignment: .center)
    }
  }

  private func section<Content: View>(
    _ title: String,
    systemImage: String,
    identifier: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Label(title, systemImage: systemImage)
        .font(DesignOSTypographyRole.title3.emphasized().font)
        .accessibilityIdentifier(identifier)
      content()
        .padding(16)
        .background(DesignOSColorRole.backgroundSecondary.color)
        .clipShape(.rect(cornerRadius: 16))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct StorybookGuidance: Identifiable {
  let title: String
  let detail: String

  var id: String { title }

  var accessibilityID: String {
    title
      .lowercased()
      .replacingOccurrences(of: " & ", with: "-")
      .replacingOccurrences(of: " ", with: "-")
  }
}

private struct StorybookCodeBlock: View {
  let storyID: String
  let code: String
  @State private var copied = false

  var body: some View {
    VStack(alignment: .trailing, spacing: 8) {
      Button(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc") {
        copyToPasteboard()
        copied = true
      }
      .buttonStyle(.bordered)
      .accessibilityIdentifier("design-os.storybook.\(storyID).copy")

      ScrollView(.horizontal) {
        Text(code)
          .font(.system(.footnote, design: .monospaced))
          .textSelection(.enabled)
          .fixedSize(horizontal: true, vertical: false)
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityIdentifier("design-os.storybook.\(storyID).code-content")
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  @MainActor
  private func copyToPasteboard() {
    #if canImport(AppKit)
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(code, forType: .string)
    #elseif canImport(UIKit)
      UIPasteboard.general.string = code
    #endif
  }
}
