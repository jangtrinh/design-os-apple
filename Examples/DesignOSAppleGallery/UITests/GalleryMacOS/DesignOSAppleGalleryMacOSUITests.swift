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

    let searchField = app.searchFields["Search stories and keywords"]
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
  func testExactDictionaryStoryShowsReadyMarker() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "tocchien.dictionary-search"]
    app.launch()
    XCTAssertTrue(
      element("design-os.gallery.story.tocchien.dictionary-search.ready", in: app).waitForExistence(
        timeout: 2))
  }

  @MainActor
  func testDirectStoryLaunchReturnsToCatalogWithNativeBackButton() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "foundation.typography"]
    app.launch()

    let storyCanvas = element("design-os.gallery.story.foundation.typography.ready", in: app)
    XCTAssertTrue(storyCanvas.waitForExistence(timeout: 2))

    let catalogBackButton = app.buttons["Catalog"]
    XCTAssertEqual(app.buttons.matching(identifier: "Catalog").count, 1)
    XCTAssertTrue(catalogBackButton.waitForExistence(timeout: 2))
    catalogBackButton.click()

    XCTAssertTrue(storyCanvas.waitForNonExistence(timeout: 2))
    XCTAssertTrue(element("design-os.gallery.catalog.ready", in: app).waitForExistence(timeout: 2))
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
  func testCatalogAndRepresentativeStoryRenderInLightDarkAndAccessibilityLayouts() {
    for appearance in ["Light", "Dark"] {
      let catalog = launch(appearance: appearance, contentSize: "UICTContentSizeCategoryL")
      XCTAssertTrue(element("design-os.gallery.catalog.ready", in: catalog).waitForExistence(timeout: 2))
      capture("macos-catalog-\(appearance.lowercased())", app: catalog)
      catalog.terminate()

      let story = launch(
        appearance: appearance,
        contentSize: "UICTContentSizeCategoryL",
        storyID: "native.content-unavailable"
      )
      XCTAssertTrue(
        element("design-os.gallery.story.native.content-unavailable.ready", in: story)
          .waitForExistence(timeout: 2)
      )
      capture("macos-story-content-unavailable-\(appearance.lowercased())", app: story)
      story.terminate()
    }

    let accessibilityStory = launch(
      appearance: "Light",
      contentSize: "UICTContentSizeCategoryAccessibilityXXXL",
      storyID: "component.list-row"
    )
    XCTAssertTrue(
      element("design-os.gallery.story.component.list-row.ready", in: accessibilityStory)
        .waitForExistence(timeout: 2)
    )
    capture("macos-story-list-row-accessibility-xxxl", app: accessibilityStory)
  }

  @MainActor
  private func launch(
    appearance: String,
    contentSize: String,
    storyID: String? = nil
  ) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = ["-AppleInterfaceStyle", appearance]
    if let storyID { app.launchArguments += ["--design-os-story", storyID] }
    app.launchEnvironment["UIPreferredContentSizeCategoryName"] = contentSize
    app.launch()
    return app
  }

  @MainActor
  private func capture(_ name: String, app: XCUIApplication) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  @MainActor
  private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }
}
