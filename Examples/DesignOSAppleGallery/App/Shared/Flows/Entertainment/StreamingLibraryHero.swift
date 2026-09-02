import SwiftUI

struct StreamingLibraryHero: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isPlaying = false
  @State private var isSaved = false
  @State private var selectedCategory = "Series"

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      categoryChips
      ZStack(alignment: .bottom) {
        StreamingMediaArtwork(crop: .mountain, cornerRadius: 12)
        LinearGradient(
          colors: [.clear, .black.opacity(0.08), .black.opacity(0.94)],
          startPoint: .top,
          endPoint: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))

        VStack(spacing: 10) {
          Text("NIGHT ATLAS")
            .font(.largeTitle.weight(.black))
            .fontDesign(.rounded)
            .tracking(-1)
          Text("Offbeat · Heartfelt · Comedy")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.82))
          primaryActions
        }
        .padding(14)
      }
      .frame(height: 500)
      .padding(.horizontal, 16)
    }
    .accessibilityIdentifier(
      "design-os.demo.entertainment.streaming-library.highlighted-hero")
  }

  private var categoryChips: some View {
    HStack(spacing: 8) {
      chip("Series")
      chip("Films")
      chip("Categories", symbol: "chevron.down")
      Spacer()
    }
    .padding(.horizontal, 16)
  }

  private func chip(_ title: String, symbol: String? = nil) -> some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        selectedCategory = title
      }
    } label: {
      HStack(spacing: 5) {
        Text(title)
        if selectedCategory == title {
          Image(systemName: "checkmark")
            .contentTransition(.symbolEffect(.replace))
        } else if let symbol {
          Image(systemName: symbol)
        }
      }
      .font(.caption.weight(.semibold))
      .padding(.horizontal, 12)
      .frame(height: 32)
      .background(.white.opacity(selectedCategory == title ? 0.24 : 0.13), in: Capsule())
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .frame(minHeight: 44)
    .accessibilityValue(selectedCategory == title ? "Selected" : "Not selected")
  }

  private var primaryActions: some View {
    HStack(spacing: 10) {
      Button {
        withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
          isPlaying.toggle()
        }
      } label: {
        Label(isPlaying ? "Pause" : "Play", systemImage: isPlaying ? "pause.fill" : "play.fill")
          .font(.subheadline.bold())
          .foregroundStyle(.black)
          .frame(maxWidth: .infinity, minHeight: 44)
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .background(.white, in: RoundedRectangle(cornerRadius: 6))
      .accessibilityIdentifier("streaming-library.primary-play")

      Button {
        withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
          isSaved.toggle()
        }
      } label: {
        Label(isSaved ? "Saved" : "My List", systemImage: isSaved ? "checkmark" : "plus")
          .contentTransition(.symbolEffect(.replace))
          .font(.subheadline.bold())
          .frame(maxWidth: .infinity, minHeight: 44)
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .background(.white.opacity(0.20), in: RoundedRectangle(cornerRadius: 6))
      .accessibilityValue(isSaved ? "On" : "Off")
    }
  }
}
