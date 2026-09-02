import DesignOSApple
import DesignOSAppleCatalog
import SwiftUI

#if canImport(AppKit)
  import AppKit
#elseif canImport(UIKit)
  import UIKit
#endif

enum GalleryDesignFloor {
  static let compactGutter: CGFloat = 16
  static let minimumHitTarget: CGFloat = 44
  static let sectionSpacing: CGFloat = 32
  static let surfaceRadius: CGFloat = 16
  static let detailMaxWidth: CGFloat = 760
  static let catalogMaxWidth: CGFloat = 1_120
}

struct StoryReferenceSection<Content: View>: View {
  let title: String
  @ViewBuilder let content: () -> Content

  init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(DesignOSTypographyRole.title2.emphasized().font)
      content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

struct StoryReferenceBadge: View {
  let label: String

  var body: some View {
    Text(label)
      .font(DesignOSTypographyRole.caption.emphasized().font)
      .foregroundStyle(DesignOSColorRole.labelSecondary.color)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(DesignOSColorRole.fillPrimary.color)
      .clipShape(.capsule)
  }
}

struct StoryReferenceGuidance: View {
  let title: String
  let detail: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(DesignOSTypographyRole.headline.font)
      Text(detail)
        .font(DesignOSTypographyRole.body.font)
        .foregroundStyle(DesignOSColorRole.labelSecondary.color)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

struct StoryReferenceCodeBlock: View {
  let storyID: DesignOSStoryID
  let code: String

  var body: some View {
    VStack(alignment: .trailing, spacing: 8) {
      StoryReferenceCopyButton(value: code, label: "Copy code")
      ScrollView(.horizontal) {
        Text(code)
          .font(.system(.footnote, design: .monospaced))
          .textSelection(.enabled)
          .fixedSize(horizontal: true, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(16)
    .background(DesignOSColorRole.backgroundSecondary.color)
    .clipShape(.rect(cornerRadius: 16))
    .accessibilityIdentifier("design-os.reference.\(storyID.rawValue).code")
  }
}

struct StoryReferenceCopyButton: View {
  let value: String
  let label: String
  var identifier: String = ""
  @State private var copied = false

  var body: some View {
    Button(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc") {
      copy()
      copied = true
    }
    .buttonStyle(.borderless)
    .frame(
      minWidth: GalleryDesignFloor.minimumHitTarget,
      minHeight: GalleryDesignFloor.minimumHitTarget
    )
    .contentShape(.rect)
    .accessibilityLabel(label)
    .accessibilityIdentifier(identifier)
  }

  @MainActor
  private func copy() {
    #if canImport(AppKit)
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(value, forType: .string)
    #elseif canImport(UIKit)
      UIPasteboard.general.string = value
    #endif
  }
}

struct StoryReferenceSourceRow: View {
  let label: String
  let value: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(label)
        .font(DesignOSTypographyRole.caption.emphasized().font)
        .foregroundStyle(DesignOSColorRole.labelSecondary.color)
      Text(value)
        .font(.system(.footnote, design: .monospaced))
        .textSelection(.enabled)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

struct StoryReferenceFactRow: View {
  let fact: StoryReferenceFact

  var body: some View {
    ViewThatFits(in: .horizontal) {
      HStack(alignment: .firstTextBaseline, spacing: 16) {
        title
        Spacer(minLength: 16)
        detail
          .multilineTextAlignment(.trailing)
      }
      VStack(alignment: .leading, spacing: 4) {
        title
        detail
          .multilineTextAlignment(.leading)
      }
    }
  }

  private var title: some View {
    Text(fact.title)
      .font(DesignOSTypographyRole.body.emphasized().font)
  }

  private var detail: some View {
    Text(fact.detail)
      .font(DesignOSTypographyRole.body.font)
      .foregroundStyle(DesignOSColorRole.labelSecondary.color)
      .fixedSize(horizontal: false, vertical: true)
  }
}
