import XCTest

final class TocChienDogfoodPilotMacOSUITests: XCTestCase {
  private let readyMarker = "design-os.tocchien.macos.story.tocchien.dictionary-search.ready"
  private let failureMarker = "design-os.tocchien.macos.story.selector-failure"

  @MainActor
  func testExactDictionaryStoryShowsReadyMarker() {
    let app = launch(["--design-os-story", "tocchien.dictionary-search"])
    XCTAssertTrue(app.staticTexts[readyMarker].waitForExistence(timeout: 2))
  }

  @MainActor
  func testTabsSelectSecondNativeDestination() {
    let app = launch(["--design-os-story", "tocchien.navigation-tabs"])
    XCTAssertTrue(
      app.staticTexts[
        "design-os.tocchien.macos.story.tocchien.navigation-tabs.ready"
      ].waitForExistence(timeout: 2))
    let activityTab = app.radioButtons["Hoạt động"]
    XCTAssertTrue(activityTab.waitForExistence(timeout: 2))
    activityTab.click()
    XCTAssertEqual(activityTab.value as? Int, 1)
    XCTAssertTrue(
      app.staticTexts["design-os.tocchien.navigation-tabs.activity.content"].waitForExistence(
        timeout: 2))
  }

  @MainActor
  func testNegativeControlShowsOwnershipBoundaryMarker() {
    let app = launch(["--design-os-story", "tocchien.champion-hero-negative-control"])
    XCTAssertTrue(
      app.staticTexts[
        "design-os.tocchien.macos.story.tocchien.champion-hero-negative-control.ready"
      ].waitForExistence(timeout: 2))
    XCTAssertTrue(
      app.otherElements["design-os.tocchien.negative-control.runtime-unavailable"].waitForExistence(
        timeout: 2))
  }

  @MainActor
  func testAbsentStoryShowsHostFailureMarker() {
    let app = launch([])
    XCTAssertTrue(app.staticTexts[failureMarker].waitForExistence(timeout: 2))
    XCTAssertTrue(app.staticTexts["E_STORY_ARGUMENT"].exists)
  }

  @MainActor
  func testUnknownStoryShowsHostFailureMarker() {
    let app = launch(["--design-os-story", "unknown.story"])
    XCTAssertTrue(app.staticTexts[failureMarker].waitForExistence(timeout: 2))
    XCTAssertTrue(app.staticTexts["E_STORY_UNKNOWN"].exists)
  }

  @MainActor
  func testOmniActStoryIsUnsupportedByTocChienHost() {
    let app = launch(["--design-os-story", "omniact.settings-shell"])
    XCTAssertTrue(app.staticTexts[failureMarker].waitForExistence(timeout: 2))
    XCTAssertTrue(app.staticTexts["E_STORY_UNSUPPORTED_HOST"].exists)
  }

  @MainActor
  func testSearchFiltersSyntheticEntriesAndShowsNoResults() {
    let app = launch(["--design-os-story", "tocchien.dictionary-search"])
    let searchField = app.searchFields["Tra từ điển"]
    XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    searchField.click()
    searchField.typeText("Ánh")
    XCTAssertTrue(app.staticTexts["Ánh sương"].waitForExistence(timeout: 2))
    clearSearchField(searchField, typedText: "Ánh")
    searchField.typeText("không-tồn-tại")
    XCTAssertTrue(
      app.staticTexts["design-os.tocchien.dictionary.empty"].waitForExistence(timeout: 2))
  }

  @MainActor
  private func launch(_ arguments: [String]) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = arguments
    app.launch()
    return app
  }

  @MainActor
  private func clearSearchField(_ field: XCUIElement, typedText: String) {
    field.click()
    field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: typedText.utf16.count))
  }
}
