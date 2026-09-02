import SwiftUI

struct SongFinderResultDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isPlaying = false
  @State private var isSaved = false

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        resultCard
        relatedEvent
      }
      .padding(.horizontal, 16)
      .padding(.top, 4)
      .padding(.bottom, 28)
    }
    .scrollIndicators(.hidden)
    .background(EntertainmentTheme.black.ignoresSafeArea())
    .foregroundStyle(EntertainmentTheme.ink)
    .navigationTitle("")
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        ShareLink(item: "Afterglow Lines — North Arcade") {
          Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Share match")
        Menu {
          Button(isSaved ? "Remove from library" : "Save to library") {
            toggleSaved()
          }
        } label: {
          Image(systemName: "ellipsis")
        }
        .accessibilityLabel("More match actions")
      }
    }
    .ignoresSafeArea(edges: .top)
    .localDemoRootIdentifier("design-os.demo.entertainment.song-finder.result")
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.hidden, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    #endif
  }

  private var resultCard: some View {
    VStack(spacing: 0) {
      resultArtwork
      resultActions
    }
    .background(EntertainmentTheme.panel)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .accessibilityIdentifier("song-finder.result-card")
  }

  private var resultArtwork: some View {
    ZStack(alignment: .bottom) {
      Image("song-finder-afterglow-cover")
        .resizable()
        .scaledToFill()
        .frame(height: 548)
        .clipped()
        .accessibilityLabel(
          "An original photograph of a singer performing under red and blue light")
      LinearGradient(
        colors: [.clear, .black.opacity(0.06), .black.opacity(0.95)],
        startPoint: .top,
        endPoint: .bottom
      )
      VStack(spacing: 18) {
        Spacer()
        HStack(alignment: .bottom, spacing: 16) {
          VStack(alignment: .leading, spacing: 5) {
            Text("Afterglow Lines")
              .font(.system(.title, design: .rounded, weight: .heavy))
            Text("North Arcade · Glass Cities")
              .font(.body.weight(.medium))
              .foregroundStyle(.white.opacity(0.84))
            Label("23,025 local matches", systemImage: "waveform")
              .font(.caption)
              .foregroundStyle(.white.opacity(0.64))
          }
          Spacer(minLength: 8)
          Button {
            togglePlaying()
          } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
              .contentTransition(.symbolEffect(.replace))
              .font(.title2.bold())
              .foregroundStyle(.white)
              .frame(width: 58, height: 58)
              .background(EntertainmentTheme.action, in: Circle())
          }
          .buttonStyle(LocalDemoPressButtonStyle())
          .accessibilityLabel(isPlaying ? "Pause preview" : "Play preview")
        }
      }
      .padding(16)
    }
    .accessibilityIdentifier("song-finder.result-art")
  }

  private var resultActions: some View {
    VStack(spacing: 12) {
      Button {
        togglePlaying()
      } label: {
        Label(isPlaying ? "Pause full song" : "Play full song", systemImage: "music.note")
          .font(.body.bold())
          .frame(maxWidth: .infinity, minHeight: 50)
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .background(EntertainmentTheme.action, in: Capsule())
      .accessibilityIdentifier("song-finder.primary-action")

      Button {
        toggleSaved()
      } label: {
        Label(
          isSaved ? "Saved to library" : "Save to library",
          systemImage: isSaved ? "checkmark" : "plus"
        )
        .font(.subheadline.bold())
        .foregroundStyle(.white.opacity(0.82))
        .frame(minHeight: 44)
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityValue(isSaved ? "On" : "Off")
    }
    .padding(16)
    .background(EntertainmentTheme.panel)
  }

  private var relatedEvent: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("North Arcade live")
        .font(.title3.bold())
      HStack(spacing: 12) {
        Image(systemName: "music.mic")
          .font(.title2)
          .frame(width: 54, height: 54)
          .background(EntertainmentTheme.panelRaised, in: RoundedRectangle(cornerRadius: 12))
        VStack(alignment: .leading, spacing: 3) {
          Text("Harbor Room")
            .font(.headline)
          Text("18 July · 8:00 PM")
            .font(.subheadline)
            .foregroundStyle(EntertainmentTheme.subdued)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(EntertainmentTheme.panel, in: RoundedRectangle(cornerRadius: 16))
    .accessibilityIdentifier("song-finder.related-event-card")
  }

  private func togglePlaying() {
    withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
      isPlaying.toggle()
    }
  }

  private func toggleSaved() {
    withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
      isSaved.toggle()
    }
  }
}
