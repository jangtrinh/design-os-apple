import SwiftUI

struct SongFinderListeningDemoView: View {
  var body: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 20)
      recognitionLink
      Spacer(minLength: 24)
      listeningStatus
      Spacer(minLength: 34)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(EntertainmentTheme.listeningBlue.ignoresSafeArea())
    .ignoresSafeArea(edges: .top)
    .navigationTitle("")
    .localDemoRootIdentifier("design-os.demo.entertainment.song-finder.listening")
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.hidden, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    #endif
  }

  private var recognitionLink: some View {
    NavigationLink(value: LocalDemoDestination.songFinderResult) {
      ZStack {
        pulseRing(356, opacity: 0.22)
        pulseRing(278, opacity: 0.28)
        pulseRing(204, opacity: 0.34)
        Circle()
          .fill(Color(red: 0.03, green: 0.46, blue: 0.95))
          .frame(width: 132, height: 132)
        Image(systemName: "waveform")
          .font(.largeTitle.weight(.bold))
          .fontDesign(.rounded)
          .foregroundStyle(.white)
          .frame(width: 108, height: 108)
          .accessibilityIdentifier("song-finder.central-mark")
      }
      .frame(width: 372, height: 372)
      .contentShape(Circle())
    }
    .buttonStyle(.plain)
    .localDemoTransitionSource(.songFinderResult)
    .accessibilityLabel("Show sample song match")
    .accessibilityHint("Opens the deterministic local result")
    .accessibilityIdentifier("design-os.demo.entertainment.song-finder.open-result")
    .overlay {
      Color.clear
        .accessibilityHidden(true)
        .accessibilityIdentifier("song-finder.listening-pulse")
    }
  }

  private func pulseRing(_ size: CGFloat, opacity: Double) -> some View {
    Circle()
      .fill(.white.opacity(opacity))
      .frame(width: size, height: size)
      .overlay { Circle().stroke(.white.opacity(0.16), lineWidth: 2) }
  }

  private var listeningStatus: some View {
    VStack(spacing: 7) {
      Image(systemName: "waveform.badge.magnifyingglass")
        .font(.title2.bold())
        .accessibilityHidden(true)
      Text("Listening for music")
        .font(.title3.bold())
      Text("Keep your device close to the sound")
        .font(.subheadline)
        .foregroundStyle(.white.opacity(0.68))
    }
    .foregroundStyle(.white)
    .multilineTextAlignment(.center)
    .padding(.horizontal, 32)
    .accessibilityElement(children: .combine)
  }
}
