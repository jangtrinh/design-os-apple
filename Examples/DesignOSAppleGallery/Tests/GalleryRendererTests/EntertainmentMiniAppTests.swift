import Foundation
import XCTest

@testable import DESIGN_OS_Apple

final class EntertainmentMiniAppTests: XCTestCase {
  @MainActor
  func testEntertainmentRootsCompile() {
    _ = StreamingLibraryBrowseDemoView()
    _ = StreamingLibraryHero()
    _ = SongFinderListeningDemoView()
    _ = SongFinderResultDemoView()
  }

  func testEntertainmentFlowsKeepExactRoutesAndAccessibilityAnchors() throws {
    let source = try entertainmentSource()
    let required = [
      "NavigationLink(value: LocalDemoDestination.songFinderResult)",
      "design-os.demo.entertainment.streaming-library.page",
      "design-os.demo.entertainment.streaming-library.highlighted-hero",
      "design-os.demo.entertainment.streaming-library.scrolled-library",
      "design-os.demo.entertainment.song-finder.listening",
      "design-os.demo.entertainment.song-finder.open-result",
      "design-os.demo.entertainment.song-finder.result",
    ]

    for anchor in required {
      XCTAssertTrue(source.contains(anchor), "Missing entertainment contract: \(anchor)")
    }
    XCTAssertFalse(source.contains("NavigationStack"))
  }

  func testCriticalVisualAnchorsAndOriginalAssetsAreDeclared() throws {
    let source = try entertainmentSource()
    let required = [
      "streaming-library-poster-atlas", "song-finder-afterglow-cover",
      "streaming-library.highlighted-hero", "streaming-library.media-rail",
      "streaming-library.primary-play", "song-finder.listening-pulse",
      "song-finder.central-mark", "song-finder.result-art", "song-finder.primary-action",
    ]
    for anchor in required {
      XCTAssertTrue(source.contains(anchor), "Missing critical visual anchor: \(anchor)")
    }

    for asset in ["streaming-library-poster-atlas", "song-finder-afterglow-cover"] {
      let imageSet = galleryRoot.appendingPathComponent(
        "Resources/LocalDemoMedia.xcassets/\(asset).imageset")
      XCTAssertTrue(
        FileManager.default.fileExists(
          atPath: imageSet.appendingPathComponent("Contents.json").path))
      XCTAssertTrue(
        FileManager.default.fileExists(atPath: imageSet.appendingPathComponent("\(asset).png").path)
      )
    }

    XCTAssertTrue(source.contains("geometry.size.width * 5"))
    XCTAssertTrue(source.contains("geometry.size.height * 3"))
    XCTAssertTrue(source.contains("@ScaledMetric(relativeTo: .largeTitle)"))
    XCTAssertTrue(source.contains("rankingNumberSize: CGFloat = 120"))
    XCTAssertTrue(source.contains(".font(.system(size: rankingNumberSize"))
    XCTAssertTrue(source.contains(".frame(width: 96, alignment: .leading)"))
    XCTAssertTrue(source.contains(".offset(x: 50)"))
    XCTAssertTrue(source.contains(".frame(width: 154, height: 148"))
    XCTAssertTrue(source.contains("Text(title.title)"))
  }

  func testSongResultPreservesTwoCardHierarchy() throws {
    let source = try String(
      contentsOf: entertainmentRoot.appendingPathComponent("SongFinderResultDemoView.swift"),
      encoding: .utf8
    )
    let required = [
      "song-finder.result-card",
      "song-finder.related-event-card",
      "VStack(spacing: 8)",
      "RoundedRectangle(cornerRadius: 16)",
      ".padding(.horizontal, 16)",
    ]

    for anchor in required {
      XCTAssertTrue(source.contains(anchor), "Missing song result card contract: \(anchor)")
    }
  }

  func testStreamingTabsOwnTheContentSelectionTheyRepresent() throws {
    let browse = try String(
      contentsOf: entertainmentRoot.appendingPathComponent("StreamingLibraryBrowseDemoView.swift"),
      encoding: .utf8)
    let tabBar = try String(
      contentsOf: entertainmentRoot.appendingPathComponent("StreamingLibraryTabBar.swift"),
      encoding: .utf8)

    XCTAssertTrue(browse.contains("@State private var selectedTab: StreamingLibraryTab = .home"))
    XCTAssertTrue(browse.contains("StreamingLibraryTabBar(selectedTab: $selectedTab)"))
    XCTAssertTrue(browse.contains("switch selectedTab"))
    XCTAssertTrue(tabBar.contains("@Binding var selectedTab: StreamingLibraryTab"))
    XCTAssertTrue(tabBar.contains("private var tabBarBackground"))
    XCTAssertTrue(tabBar.contains(".ignoresSafeArea(edges: .bottom)"))
    XCTAssertTrue(tabBar.contains("Rectangle().fill(EntertainmentTheme.panel)"))
    XCTAssertFalse(tabBar.contains(".ultraThinMaterial"))
  }

  func testEntertainmentSourcesRemainGenericAndCleanRoomSafe() throws {
    let source = try entertainmentSource().lowercased()
    let forbidden = [
      "netflix", "shazam", "apple music", "hyukoh", "bridgerton", "mobbin",
      "hbo", "spotify", "disney", "prime video",
    ]
    for brand in forbidden {
      XCTAssertFalse(source.contains(brand), "Forbidden brand in entertainment source: \(brand)")
    }
  }

  private func entertainmentSource() throws -> String {
    try sourceNames.map { name in
      try String(contentsOf: entertainmentRoot.appendingPathComponent(name), encoding: .utf8)
    }.joined(separator: "\n")
  }

  private let sourceNames = [
    "EntertainmentTheme.swift", "StreamingLibraryFixtures.swift",
    "StreamingMediaArtwork.swift", "StreamingLibraryBrowseDemoView.swift",
    "StreamingLibraryHero.swift", "SongFinderListeningDemoView.swift",
    "SongFinderResultDemoView.swift",
  ]

  private var galleryRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  }

  private var entertainmentRoot: URL {
    galleryRoot.appendingPathComponent("App/Shared/Flows/Entertainment")
  }
}
