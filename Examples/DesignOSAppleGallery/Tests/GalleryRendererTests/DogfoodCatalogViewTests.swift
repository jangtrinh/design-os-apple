import DesignOSAppleCatalog
import XCTest

@testable import DESIGN_OS_Apple

final class DogfoodCatalogViewTests: XCTestCase {
  func testEmptyCatalogRemainsEmptyForAnEmptyQuery() {
    XCTAssertEqual(DogfoodCatalogView.filteredStories([], query: ""), [])
  }

  func testEmptyQueryPreservesEveryAdmittedStoryInAuthorityOrder() {
    XCTAssertEqual(
      DogfoodCatalogView.filteredStories(DesignOSReleaseCatalog.stories, query: ""),
      DesignOSReleaseCatalog.stories
    )
  }

  func testUnknownQueryReturnsNoResults() {
    XCTAssertTrue(
      DogfoodCatalogView.filteredStories(
        DesignOSReleaseCatalog.stories,
        query: "not-an-admitted-story"
      ).isEmpty
    )
  }

  func testSearchMatchesStableIDTitleAndSummaryWithoutChangingOrder() {
    let stories = DesignOSReleaseCatalog.stories

    XCTAssertEqual(
      DogfoodCatalogView.filteredStories(stories, query: "tocchien.dictionary-search").map(\.id),
      [.tocchienDictionarySearch]
    )
    XCTAssertEqual(
      DogfoodCatalogView.filteredStories(stories, query: "COMMAND ROW").map(\.id),
      [.omniactCommandRow]
    )
    XCTAssertEqual(
      DogfoodCatalogView.filteredStories(stories, query: "empty state").map(\.id),
      [.contentUnavailable]
    )
    XCTAssertEqual(
      DogfoodCatalogView.filteredStories(stories, query: "build a list row").map(\.id),
      [.listRow]
    )
  }

  func testEveryAdmittedStoryHasOneUniqueGeneratedThumbnailAssetName() {
    let names = DesignOSStoryID.currentExecutableCases.map(CatalogStoryThumbnail.assetName(for:))

    XCTAssertEqual(Set(names).count, DesignOSStoryID.currentExecutableCases.count)
    XCTAssertEqual(
      names,
      DesignOSStoryID.currentExecutableCases.map {
        "catalog-\($0.rawValue.replacingOccurrences(of: ".", with: "-"))"
      }
    )
  }

  func testEveryAdmittedStoryBelongsToOneStableCatalogSection() {
    let expected: [CatalogStorySection: [DesignOSStoryID]] = [
      .foundations: [
        .profileCustomization, .colorRoles, .platformSemanticColor, .typographyRoles,
        .surfaceRoles,
      ],
      .components: [.listRow, .sidebarRow],
      .nativePatterns: [
        .buttonAndToolbarActions, .contentUnavailable, .elevatedBackground,
        .hierarchicalStyle, .homeScreenQuickActions, .listSidebarAndDisclosure,
        .materialAndGlassSurface, .menuContextAndEditActions, .navigationTabsAndToolbars,
        .pickerAndDateColorInput, .presentationAndShare, .progressSliderStepper,
        .textSearchAndKeyboardInput, .systemDeviceChromeHost,
      ],
      .extensionRecipes: [.extensionWidget, .extensionControlWidget],
      .productStories: [
        .omniactSettingsShell, .omniactCommandRow, .tocchienDictionarySearch,
        .tocchienNavigationTabs, .tocchienChampionHeroNegativeControl,
      ],
      .implementationInternals: [
        .accessorySlotLayout, .sectionContentLayout, .sidebarToolbarContent, .symbolContent,
      ],
    ]

    for section in CatalogStorySection.allCases {
      XCTAssertEqual(
        DesignOSStoryID.currentExecutableCases.filter {
          CatalogStorySection.section(for: $0) == section
        },
        expected[section]
      )
    }
  }

  func testCatalogLayoutContractUsesCompactGutterAndAccessibilityColumn() {
    XCTAssertEqual(DogfoodCatalogView.contentPadding, 16)
    XCTAssertEqual(DogfoodCatalogView.columnMode(for: .large), .adaptive)
    XCTAssertEqual(DogfoodCatalogView.columnMode(for: .accessibility1), .single)
    XCTAssertEqual(DogfoodCatalogView.columnMode(for: .accessibility5), .single)
    XCTAssertEqual(
      DogfoodCatalogView.cardPresentation(
        horizontalSizeClass: .compact, dynamicTypeSize: .large, isSearching: false),
      .compactRow
    )
    XCTAssertEqual(
      DogfoodCatalogView.cardPresentation(
        horizontalSizeClass: .regular, dynamicTypeSize: .large, isSearching: false),
      .card
    )
    XCTAssertEqual(
      DogfoodCatalogView.cardPresentation(
        horizontalSizeClass: .regular, dynamicTypeSize: .large, isSearching: true),
      .compactRow
    )
    XCTAssertEqual(
      DogfoodCatalogView.cardPresentation(
        horizontalSizeClass: .compact, dynamicTypeSize: .accessibility5, isSearching: false),
      .accessibilityCard
    )
  }

  func testCatalogSharedChromeUsesDesignFloorGeometryAndSemanticType() throws {
    let source = try gallerySource(named: "DogfoodCatalogCard")
    let catalog = try gallerySource(named: "DogfoodCatalogView")

    for forbidden in [
      ".padding(10)",
      "spacing: 6",
      ".frame(width: 88, height: 66)",
      ".font(.system(size:",
      "DesignOSTypographyRole.caption2",
    ] {
      XCTAssertFalse(source.contains(forbidden), "Catalog floor rejects \(forbidden)")
    }

    XCTAssertTrue(source.contains("GalleryDesignFloor.minimumHitTarget"))
    XCTAssertTrue(source.contains("case accessibilityCard"))
    XCTAssertTrue(catalog.contains("dynamicTypeSize.isAccessibilitySize"))
    XCTAssertTrue(catalog.contains("Search stories and keywords"))
    XCTAssertTrue(source.contains("Ask AI: "))
  }

  func testCatalogThumbnailIsClippedToItsAssignedCardFrame() throws {
    let source = try gallerySource(named: "CatalogStoryThumbnail")

    XCTAssertTrue(source.contains("GeometryReader"))
    XCTAssertTrue(source.contains("proxy.size.width"))
    XCTAssertTrue(source.contains("proxy.size.height"))
    XCTAssertTrue(source.contains(".clipped()"))
  }

  func testGalleryDesignFloorGeometryIsExplicitAndGridAligned() {
    XCTAssertEqual(GalleryDesignFloor.compactGutter, 16)
    XCTAssertEqual(GalleryDesignFloor.minimumHitTarget, 44)
    XCTAssertEqual(GalleryDesignFloor.surfaceRadius, 16)
    XCTAssertEqual(GalleryDesignFloor.detailMaxWidth, 760)
    XCTAssertEqual(GalleryDesignFloor.catalogMaxWidth, 1_120)

    for value in [
      GalleryDesignFloor.compactGutter,
      GalleryDesignFloor.minimumHitTarget,
      GalleryDesignFloor.sectionSpacing,
      GalleryDesignFloor.surfaceRadius,
      GalleryDesignFloor.detailMaxWidth,
      GalleryDesignFloor.catalogMaxWidth,
    ] {
      XCTAssertEqual(value.truncatingRemainder(dividingBy: 4), 0, "Off-grid: \(value)")
    }
  }

  private func gallerySource(named name: String) throws -> String {
    let file =
      galleryRoot
      .appendingPathComponent("App/Shared/Dogfood/Gallery")
      .appendingPathComponent("\(name).swift")
    return try String(contentsOf: file, encoding: .utf8)
  }

  private var galleryRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  }
}
