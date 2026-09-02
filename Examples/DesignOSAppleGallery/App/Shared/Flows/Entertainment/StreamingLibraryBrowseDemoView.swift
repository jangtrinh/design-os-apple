import SwiftUI

struct StreamingLibraryBrowseDemoView: View {
  @ScaledMetric(relativeTo: .largeTitle) private var rankingNumberSize: CGFloat = 120
  @State private var selectedTab: StreamingLibraryTab = .home
  @State private var toolbarNotice: StreamingToolbarNotice?

  var body: some View {
    ScrollView {
      selectedContent
        .padding(.top, 8)
        .padding(.bottom, 34)
    }
    .scrollIndicators(.hidden)
    .background(EntertainmentTheme.black.ignoresSafeArea())
    .foregroundStyle(EntertainmentTheme.ink)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      StreamingLibraryTabBar(selectedTab: $selectedTab)
    }
    .navigationTitle(selectedTab.navigationTitle)
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Button {
          toolbarNotice = .downloads
        } label: {
          Image(systemName: "arrow.down.to.line")
        }
        .accessibilityLabel("Downloads")
        Button {
          toolbarNotice = .search
        } label: {
          Image(systemName: "magnifyingglass")
        }
        .accessibilityLabel("Search library")
      }
    }
    .localDemoRootIdentifier("design-os.demo.entertainment.streaming-library.page")
    .alert(item: $toolbarNotice) { notice in
      Alert(
        title: Text(notice.title),
        message: Text(notice.message),
        dismissButton: .cancel(Text("Done")))
    }
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(EntertainmentTheme.black, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    #endif
  }

  @ViewBuilder private var selectedContent: some View {
    VStack(alignment: .leading, spacing: 14) {
      Color.clear
        .frame(height: 0)
        .accessibilityElement()
        .accessibilityIdentifier(
          "design-os.demo.entertainment.streaming-library.tab-state.\(selectedTab.rawValue)")
      switch selectedTab {
      case .home:
        StreamingLibraryHero()
        rankedRail
        posterRail("Watch in one weekend", titles: StreamingLibraryFixtures.weekend)
        landscapeRail("Fresh episodes", titles: StreamingLibraryFixtures.freshEpisodes)
        posterRail("Critics' science picks", titles: StreamingLibraryFixtures.criticsPicks)
      case .newAndHot:
        landscapeRail("Fresh episodes", titles: StreamingLibraryFixtures.freshEpisodes)
        posterRail("Trending this week", titles: StreamingLibraryFixtures.topTen)
      case .myLibrary:
        posterRail("Saved for you", titles: StreamingLibraryFixtures.weekend)
        posterRail("Continue watching", titles: StreamingLibraryFixtures.criticsPicks)
      }
    }
  }

  private var rankedRail: some View {
    mediaSection(
      "Top 10 tonight",
      identifier: "design-os.demo.entertainment.streaming-library.scrolled-library"
    ) {
      ScrollView(.horizontal) {
        HStack(spacing: 4) {
          ForEach(Array(StreamingLibraryFixtures.topTen.enumerated()), id: \.element.id) {
            index, title in
            rankedArtwork(index: index, title: title)
          }
        }
        .padding(.horizontal, 16)
      }
      .scrollIndicators(.hidden)
    }
  }

  private func rankedArtwork(index: Int, title: StreamingLibraryTitle) -> some View {
    ZStack(alignment: .bottomLeading) {
      Text("\(index + 1)")
        .font(.system(size: rankingNumberSize, weight: .black, design: .rounded))
        .stroke(color: .white, lineWidth: 2)
        .frame(width: 96, alignment: .leading)
      posterArtwork(title)
        .frame(width: 96, height: 144)
        .offset(x: 50)
    }
    .frame(width: 154, height: 148, alignment: .bottomLeading)
  }

  private func landscapeRail(_ heading: String, titles: [StreamingLibraryTitle]) -> some View {
    mediaSection(heading) {
      ScrollView(.horizontal) {
        HStack(spacing: 8) {
          ForEach(titles) { title in
            VStack(alignment: .leading, spacing: 4) {
              posterArtwork(title)
                .frame(width: 150, height: 88)
              Text(title.subtitle).font(.caption).foregroundStyle(EntertainmentTheme.subdued)
            }
            .frame(width: 150, alignment: .leading)
          }
        }
        .padding(.horizontal, 16)
      }
      .scrollIndicators(.hidden)
    }
  }

  private func posterRail(_ heading: String, titles: [StreamingLibraryTitle]) -> some View {
    mediaSection(heading) {
      ScrollView(.horizontal) {
        HStack(spacing: 8) {
          ForEach(titles) { title in
            posterArtwork(title)
              .frame(width: 104, height: 154)
          }
        }
        .padding(.horizontal, 16)
      }
      .scrollIndicators(.hidden)
    }
  }

  private func posterArtwork(_ title: StreamingLibraryTitle) -> some View {
    ZStack(alignment: .bottomLeading) {
      StreamingMediaArtwork(crop: title.crop, cornerRadius: 5)
      LinearGradient(
        colors: [.clear, .black.opacity(0.88)], startPoint: .center, endPoint: .bottom)
      Text(title.title)
        .font(.caption.bold())
        .foregroundStyle(.white)
        .lineLimit(2)
        .padding(7)
    }
    .clipShape(RoundedRectangle(cornerRadius: 5))
  }

  private func mediaSection<Content: View>(
    _ title: String,
    identifier: String = "streaming-library.media-rail",
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: 7) {
      Text(title)
        .font(.headline)
        .padding(.horizontal, 16)
        .accessibilityIdentifier(identifier)
      content()
    }
  }
}

private enum StreamingToolbarNotice: String, Identifiable {
  case downloads, search

  var id: String { rawValue }
  var title: String { self == .downloads ? "Downloads" : "Search" }
  var message: String {
    self == .downloads
      ? "Downloaded titles would appear in this local library."
      : "Search is ready to filter this reusable catalog."
  }
}

extension Text {
  fileprivate func stroke(color: Color, lineWidth: CGFloat) -> some View {
    ZStack {
      ForEach(0..<8, id: \.self) { angle in
        self.foregroundStyle(color)
          .offset(
            x: cos(Double(angle) * .pi / 4) * lineWidth,
            y: sin(Double(angle) * .pi / 4) * lineWidth)
      }
      self.foregroundStyle(.black)
    }
  }
}
