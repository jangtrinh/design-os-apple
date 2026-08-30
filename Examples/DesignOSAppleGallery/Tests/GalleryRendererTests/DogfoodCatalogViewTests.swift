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
      DogfoodCatalogView.filteredStories(stories, query: "command composition").map(\.id),
      [.omniactHUDAutocompleteMaterial]
    )
  }
}
