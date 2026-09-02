import SwiftUI

enum StreamingMediaCrop: Int, Hashable, Sendable {
  case mountain
  case neonDetective
  case oceanDive
  case orbit
  case kitchenRomance
  case desert
  case arctic
  case jazzClub
  case forest
  case courtroom
  case coast
  case futureTrain
  case volcano
  case moonDance
  case botanical
}

struct StreamingMediaArtwork: View {
  let crop: StreamingMediaCrop
  var cornerRadius: CGFloat = 0

  var body: some View {
    GeometryReader { geometry in
      Image("streaming-library-poster-atlas")
        .resizable()
        .scaledToFill()
        .frame(width: geometry.size.width * 5, height: geometry.size.height * 3)
        .offset(
          x: -CGFloat(crop.rawValue % 5) * geometry.size.width,
          y: -CGFloat(crop.rawValue / 5) * geometry.size.height)
    }
    .clipped()
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    .accessibilityLabel(accessibilityLabel)
  }

  private var accessibilityLabel: String {
    "Original fictional movie artwork"
  }
}

struct StreamingMediaBoard: View {
  var body: some View {
    Image("streaming-library-poster-atlas")
      .resizable()
      .scaledToFill()
      .clipped()
      .accessibilityLabel("Fifteen original cinematic scenes from the local media library")
  }
}
