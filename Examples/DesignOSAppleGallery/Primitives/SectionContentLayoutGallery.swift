import SwiftUI

struct SectionContentLayoutGallery: View {
  var body: some View {
    HStack(spacing: 8) {
      Text("Section title").frame(maxWidth: .infinity, alignment: .leading)
      Text("Details").foregroundStyle(.secondary)
    }
  }
}
