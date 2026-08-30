import DesignOSApple
import SwiftUI

struct FoundationGallery: View {
  private let typography: [(String, DesignOSTypographyRole)] = [
    ("Large title", .largeTitle),
    ("Title", .title),
    ("Title 2", .title2),
    ("Title 3", .title3),
    ("Headline", .headline),
    ("Body", .body),
    ("Callout", .callout),
    ("Footnote", .footnote),
    ("Caption", .caption),
  ]

  private let colors: [(String, DesignOSColorRole)] = [
    ("Primary label", .labelPrimary),
    ("Secondary label", .labelSecondary),
    ("Primary fill", .fillPrimary),
    ("Separator", .separator),
    ("Blue", .blue),
    ("Green", .green),
    ("Orange", .orange),
    ("Red", .red),
  ]

  var body: some View {
    List {
      Section("Dynamic typography") {
        ForEach(typography, id: \.0) { name, role in
          Text(name)
            .font(role.font)
        }
      }

      Section("Semantic colors") {
        ForEach(colors, id: \.0) { name, role in
          LabeledContent(name) {
            Circle()
              .fill(role.color)
              .frame(width: 28, height: 28)
              .accessibilityHidden(true)
          }
        }
      }
    }
  }
}
