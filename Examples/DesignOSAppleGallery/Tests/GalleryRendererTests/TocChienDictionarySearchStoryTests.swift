import XCTest

@testable import DESIGN_OS_Apple

final class TocChienDictionarySearchStoryTests: XCTestCase {
  func testEmptyQueryReturnsEverySyntheticEntry() {
    XCTAssertEqual(
      TocChienDictionarySearchStory.filteredEntries(TocChienDictionaryFixtures.entries, query: ""),
      TocChienDictionaryFixtures.entries)
  }

  func testTermAndDescriptionQueriesUseCaseInsensitiveLocalFiltering() {
    let termMatches = TocChienDictionarySearchStory.filteredEntries(
      TocChienDictionaryFixtures.entries, query: "ÁNH")
    let descriptionMatches = TocChienDictionarySearchStory.filteredEntries(
      TocChienDictionaryFixtures.entries, query: "cục bộ")

    XCTAssertEqual(termMatches.map(\.id), ["anh-suong"])
    XCTAssertEqual(descriptionMatches.map(\.id), ["gio-nhe", "mua-xanh"])
  }

  func testLongDescriptionIsReturnedWithoutTruncation() {
    let entry = try? XCTUnwrap(
      TocChienDictionarySearchStory.filteredEntries(
        TocChienDictionaryFixtures.entries, query: "dấu ba chấm"
      ).first)
    XCTAssertNotNil(entry)
    XCTAssertGreaterThan(entry?.description.count ?? 0, 280)
    XCTAssertTrue(entry?.description.contains("dấu ba chấm") == true)
  }

  func testNoResultReturnsAnEmptyCollection() {
    XCTAssertTrue(
      TocChienDictionarySearchStory.filteredEntries(
        TocChienDictionaryFixtures.entries, query: "không-tồn-tại"
      ).isEmpty)
  }
}
