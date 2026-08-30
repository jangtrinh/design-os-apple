import DesignOSApple
import SwiftUI

struct ColorRolesGallery: View {
  private let roles: [(String, DesignOSColorRole)] = [
    ("Primary label", .labelPrimary),
    ("Secondary label", .labelSecondary),
    ("Primary background", .backgroundPrimary),
    ("Primary fill", .fillPrimary),
    ("Separator", .separator),
    ("Blue", .blue),
    ("Green", .green),
    ("Orange", .orange),
    ("Red", .red),
  ]

  var body: some View {
    ForEach(roles, id: \.0) { name, role in
      LabeledContent(name) {
        Circle()
          .fill(role.color)
          .frame(width: 28, height: 28)
          .accessibilityHidden(true)
      }
    }
  }
}
