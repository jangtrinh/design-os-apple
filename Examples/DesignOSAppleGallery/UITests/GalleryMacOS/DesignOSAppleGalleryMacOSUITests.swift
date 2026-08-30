import XCTest

final class DesignOSAppleGalleryMacOSUITests: XCTestCase {
  @MainActor
  func testAbsentStoryOpensCatalog() {
    let app = XCUIApplication()
    app.launch()
    XCTAssertTrue(element("design-os.gallery.catalog.ready", in: app).waitForExistence(timeout: 2))
    XCTAssertFalse(app.staticTexts["Catalog ready"].exists)
  }

  @MainActor
  func testCatalogSearchOpensDictionaryStory() {
    let app = XCUIApplication()
    app.launch()

    let searchField = app.searchFields["Search admitted stories"]
    XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    searchField.click()
    searchField.typeText("tocchien.dictionary-search")

    let dictionaryRow = element(
      "design-os.gallery.catalog.story.tocchien.dictionary-search", in: app)
    XCTAssertTrue(dictionaryRow.waitForExistence(timeout: 2))
    dictionaryRow.click()
    XCTAssertTrue(
      element("design-os.gallery.story.tocchien.dictionary-search.ready", in: app)
        .waitForExistence(timeout: 2)
    )
    XCTAssertFalse(app.staticTexts["Story ready"].exists)
  }

  @MainActor
  func testExactSettingsStoryShowsReadyMarker() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "omniact.settings-shell"]
    app.launch()
    XCTAssertTrue(
      element("design-os.gallery.story.omniact.settings-shell.ready", in: app).waitForExistence(
        timeout: 2)
    )
  }

  @MainActor
  func testExactCommandRowShowsReadyMarker() {
    let app = XCUIApplication()
    app.launchArguments = [
      "--design-os-story", "omniact.command-row", "--design-os-profile", "omniact",
    ]
    app.launch()
    XCTAssertTrue(
      element("design-os.gallery.story.omniact.command-row.ready", in: app).waitForExistence(
        timeout: 2)
    )
  }

  @MainActor
  func testExactHUDStoryShowsReadyMarker() {
    let app = XCUIApplication()
    app.launchArguments = [
      "--design-os-story", "omniact.hud-autocomplete-material", "--design-os-profile",
      "omniact-hud",
    ]
    app.launch()
    XCTAssertTrue(
      element("design-os.gallery.story.omniact.hud-autocomplete-material.ready", in: app)
        .waitForExistence(timeout: 2))
  }

  @MainActor
  func testExactDictionaryStoryShowsReadyMarker() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "tocchien.dictionary-search"]
    app.launch()
    XCTAssertTrue(
      element("design-os.gallery.story.tocchien.dictionary-search.ready", in: app).waitForExistence(
        timeout: 2))
  }

  @MainActor
  func testTabsSelectSecondNativeDestination() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "tocchien.navigation-tabs"]
    app.launch()
    XCTAssertTrue(
      element("design-os.gallery.story.tocchien.navigation-tabs.ready", in: app).waitForExistence(
        timeout: 2))
    let activityTab = app.radioButtons["Hoạt động"]
    XCTAssertTrue(activityTab.waitForExistence(timeout: 2))
    activityTab.tap()
    XCTAssertEqual(activityTab.value as? Int, 1)
    XCTAssertTrue(
      app.staticTexts["design-os.tocchien.navigation-tabs.activity.content"].waitForExistence(
        timeout: 2))
  }

  @MainActor
  func testNegativeControlShowsOwnershipBoundaryMarker() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "tocchien.champion-hero-negative-control"]
    app.launch()
    XCTAssertTrue(
      element(
        "design-os.gallery.story.tocchien.champion-hero-negative-control.ready", in: app
      ).waitForExistence(timeout: 2))
    XCTAssertTrue(
      app.otherElements["design-os.tocchien.negative-control.runtime-unavailable"].waitForExistence(
        timeout: 2))
  }

  @MainActor
  func testUnknownStoryShowsFailureMarker() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "unknown.story"]
    app.launch()
    XCTAssertTrue(
      app.staticTexts["design-os.gallery.story.selector-failure"].waitForExistence(timeout: 2))
  }

  @MainActor
  private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }
}
