import SwiftUI

struct AccessorySlotLayoutGallery: View {
  var body: some View {
    LabeledContent("Caller-owned accessories") {
      HStack(spacing: 8) {
        Text("New").font(.caption)
        Image(systemName: "info.circle")
      }
    }
  }
}
