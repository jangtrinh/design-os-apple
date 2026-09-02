extension LocalDemoDefinition {
  static let entertainmentDefinitions: [Self] = [
    .init(
      id: "demo.entertainment.streaming-library", section: .entertainment,
      title: "Streaming Library", flowLabel: "Highlighted movie → browse rails",
      symbolName: "play.rectangle.fill", imageAssetName: "demo-streaming-library-thumbnail",
      tint: .cinemaRed, entryDestination: .streamingLibraryBrowse,
      detailDestination: .streamingLibraryBrowse,
      states: [
        .init(
          id: "streaming-library.highlighted-hero", title: "Highlighted movie",
          view: "StreamingLibraryBrowseDemoView"),
        .init(
          id: "streaming-library.scrolled-library", title: "Browse rails",
          view: "StreamingLibraryBrowseDemoView"),
      ],
      patterns: ["Immersive highlighted hero", "Scroll-revealed media rails"],
      nativeAPIs: ["ScrollView", "Image", "Button"],
      sourcePaths: streamingPaths,
      assetNames: ["demo-streaming-library-thumbnail", "streaming-library-poster-atlas"],
      platforms: applePlatforms, distribution: .localOnly),
    .init(
      id: "demo.entertainment.song-finder", section: .entertainment,
      title: "Song Finder", flowLabel: "Listening → match result",
      symbolName: "waveform", imageAssetName: "demo-song-finder-thumbnail",
      tint: .electricBlue, entryDestination: .songFinderListening,
      detailDestination: .songFinderResult,
      states: [
        .init(id: "song-finder.listening", title: "Listening", view: "SongFinderListeningDemoView"),
        .init(
          id: "song-finder.match-result", title: "Match result", view: "SongFinderResultDemoView"),
      ],
      patterns: ["Concentric recognition state", "Artwork-led match result"],
      nativeAPIs: ["Canvas", "NavigationLink", "Image", "Button"],
      sourcePaths: songFinderPaths,
      assetNames: ["demo-song-finder-thumbnail", "song-finder-afterglow-cover"],
      platforms: applePlatforms, distribution: .localOnly),
  ]

  private static let themePath = ["App/Shared/Flows/Entertainment/EntertainmentTheme.swift"]
  private static let streamingPaths =
    [
      "StreamingLibraryBrowseDemoView", "StreamingLibraryHero",
      "StreamingLibraryFixtures", "StreamingMediaArtwork", "StreamingLibraryTabBar",
    ].map { "App/Shared/Flows/Entertainment/\($0).swift" } + themePath + sharedMotionPaths
  private static let songFinderPaths =
    ["SongFinderListeningDemoView", "SongFinderResultDemoView"]
    .map { "App/Shared/Flows/Entertainment/\($0).swift" } + themePath + sharedMotionPaths
}
