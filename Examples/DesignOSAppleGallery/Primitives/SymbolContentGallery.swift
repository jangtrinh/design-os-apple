import SwiftUI

struct SymbolContentGallery: View {
  var body: some View {
    HStack(spacing: 20) {
      Image(systemName: "photo").font(.title)
      Image(systemName: "person.crop.circle.fill").font(.largeTitle)
      RoundedRectangle(cornerRadius: 7).fill(.blue).frame(width: 30, height: 30)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Symbol content shape examples")
  }
}
