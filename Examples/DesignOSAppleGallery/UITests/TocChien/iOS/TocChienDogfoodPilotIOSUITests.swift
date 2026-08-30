import XCTest

final class TocChienDogfoodPilotIOSUITests: XCTestCase {
  private let readyMarker = "design-os.tocchien.ios.story.tocchien.dictionary-search.ready"
  private let failureMarker = "design-os.tocchien.ios.story.selector-failure"

  @MainActor
  func testExactDictionaryStoryShowsReadyMarker() {
    let app = launch(["--design-os-story", "tocchien.dictionary-search"])
    XCTAssertTrue(app.staticTexts[readyMarker].waitForExistence(timeout: 2))
  }

  @MainActor
  func testTabsSelectSecondNativeDestination() {
    let app = launch(["--design-os-story", "tocchien.navigation-tabs"])
    XCTAssertTrue(
      app.staticTexts["design-os.tocchien.ios.story.tocchien.navigation-tabs.ready"]
        .waitForExistence(
          timeout: 2))
    let activityTab = app.buttons["Hoạt động"]
    XCTAssertTrue(activityTab.waitForExistence(timeout: 2))
    activityTab.tap()
    XCTAssertTrue(activityTab.isSelected)
    XCTAssertTrue(
      app.staticTexts["design-os.tocchien.navigation-tabs.activity.content"].waitForExistence(
        timeout: 2))
  }

  @MainActor
  func testNegativeControlShowsOwnershipBoundaryMarker() {
    let app = launch(["--design-os-story", "tocchien.champion-hero-negative-control"])
    XCTAssertTrue(
      app.staticTexts[
        "design-os.tocchien.ios.story.tocchien.champion-hero-negative-control.ready"
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
    searchField.tap()
    searchField.typeText("Ánh")
    XCTAssertTrue(app.staticTexts["Ánh sương"].waitForExistence(timeout: 2))
    clearSearchField(searchField, typedText: "Ánh")
    searchField.typeText("không-tồn-tại")
    XCTAssertTrue(
      app.staticTexts["design-os.tocchien.dictionary.empty"].waitForExistence(timeout: 2))
  }

  @MainActor
  func testDictionarySupportsAccessibilityExtraExtraExtraLarge() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "tocchien.dictionary-search"]
    app.launchEnvironment["UIPreferredContentSizeCategoryName"] = "UICTContentSizeCategoryXXXL"
    app.launch()
    XCTAssertTrue(app.staticTexts[readyMarker].waitForExistence(timeout: 2))
    XCTAssertTrue(app.staticTexts["Mưa xanh"].waitForExistence(timeout: 2))
    app.swipeUp()
    let longDescription = app.descendants(matching: .any)[
      "design-os.tocchien.dictionary.description.mua-xanh"
    ]
    XCTAssertTrue(longDescription.waitForExistence(timeout: 2))
    let accessibilityValue = longDescription.value as? String ?? ""
    let normalizedValue = accessibilityValue.split(whereSeparator: \.isWhitespace).joined(
      separator: " ")
    XCTAssertTrue(
      normalizedValue.contains("không bị cắt ngắn"),
      "The long description must remain complete in accessibility output."
    )
    XCTAssertFalse(accessibilityValue.contains("…"))
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
    field.tap()
    field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: typedText.utf16.count))
  }
}
