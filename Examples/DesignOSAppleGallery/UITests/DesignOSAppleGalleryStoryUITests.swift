import XCTest

final class DesignOSAppleGalleryStoryUITests: XCTestCase {
  @MainActor
  func testExactSettingsSelectorExposesCanvasWithoutVisibleReadyText() {
    assertExactSelector(storyID: "omniact.settings-shell")
  }

  @MainActor
  func testExactCommandRowSelectorExposesCanvasWithoutVisibleReadyText() {
    assertExactSelector(storyID: "omniact.command-row")
  }

  @MainActor
  func testExactDictionarySelectorExposesCanvasWithoutVisibleReadyText() {
    assertExactSelector(storyID: "tocchien.dictionary-search")
  }

  @MainActor
  func testExactTabsSelectorExposesCanvasWithoutVisibleReadyText() {
    assertExactSelector(storyID: "tocchien.navigation-tabs")
  }

  @MainActor
  func testExactNegativeControlSelectorExposesCanvasWithoutVisibleReadyText() {
    assertExactSelector(storyID: "tocchien.champion-hero-negative-control")
  }

  @MainActor
  func testMalformedStorySelectorShowsFailureMarker() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story"]
    app.launch()

    XCTAssertTrue(
      element("design-os.gallery.story.selector-failure", in: app).waitForExistence(
        timeout: galleryUITestTimeout))
  }

  @MainActor
  func testCatalogDictionarySearchPreservesLargeTextAndKeyboard() {
    let app = XCUIApplication()
    app.launchEnvironment["UIPreferredContentSizeCategoryName"] =
      "UICTContentSizeCategoryAccessibilityXXXL"
    app.launch()

    let catalogSearch = app.searchFields["Search stories and keywords"]
    focusAndType("tocchien.dictionary-search", into: catalogSearch, in: app)
    let dictionaryRow = element(
      "design-os.gallery.catalog.story.tocchien.dictionary-search", in: app)
    XCTAssertTrue(dictionaryRow.waitForExistence(timeout: galleryUITestTimeout))
    dictionaryRow.tap()

    XCTAssertTrue(
      element("design-os.gallery.story.tocchien.dictionary-search.ready", in: app)
        .waitForExistence(timeout: galleryUITestTimeout))
    openInteractiveExample(in: app)
    let dictionarySearch = app.searchFields["Tra từ điển"]
    focusAndType("Mưa xanh", into: dictionarySearch, in: app)

    let longDescription = element(
      "design-os.tocchien.dictionary.description.mua-xanh", in: app)
    XCTAssertTrue(longDescription.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(longDescription.isHittable)
    XCTAssertTrue(app.keyboards.firstMatch.exists)

    let accessibilityValue = longDescription.value as? String ?? ""
    let normalizedValue = accessibilityValue.split(whereSeparator: \.isWhitespace).joined(
      separator: " ")
    XCTAssertTrue(normalizedValue.contains("không bị cắt ngắn"))
    XCTAssertFalse(accessibilityValue.contains("…"))
    XCTAssertFalse(accessibilityValue.contains("..."))
  }

  @MainActor
  func testRepresentativeStoryCanvasesPassStructuralAccessibilityAudit() throws {
    let auditTypes: XCUIAccessibilityAuditType = [
      .elementDetection,
      .hitRegion,
      .sufficientElementDescription,
      .trait,
    ]
    let stories = [
      (
        "tocchien.dictionary-search",
        "design-os.gallery.story.tocchien.dictionary-search.ready",
        "Tra từ điển"
      ),
      (
        "omniact.command-row",
        "design-os.gallery.story.omniact.command-row.ready",
        "Polish selected text enabled"
      ),
    ]

    for (storyID, readinessIdentifier, descendantLabel) in stories {
      let app =
        storyID == "tocchien.dictionary-search"
        ? launchCatalogStory(storyID)
        : launchStory(storyID)
      XCTAssertTrue(
        element(readinessIdentifier, in: app).waitForExistence(timeout: galleryUITestTimeout)
      )
      openInteractiveExample(in: app)
      let descendant =
        storyID == "tocchien.dictionary-search"
        ? app.searchFields[descendantLabel]
        : app.switches[descendantLabel]
      XCTAssertTrue(descendant.waitForExistence(timeout: galleryUITestTimeout))
      try app.performAccessibilityAudit(for: auditTypes)
      app.terminate()
    }
  }

  @MainActor
  private func launchStory(_ storyID: String) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", storyID]
    app.launch()
    return app
  }

  @MainActor
  private func assertExactSelector(storyID: String) {
    let app = launchStory(storyID)
    let readinessIdentifier = "design-os.gallery.story.\(storyID).ready"
    XCTAssertTrue(
      element(readinessIdentifier, in: app).waitForExistence(timeout: galleryUITestTimeout)
    )
    XCTAssertFalse(app.staticTexts["Story ready"].exists)
  }

  @MainActor
  private func launchCatalogStory(_ storyID: String) -> XCUIApplication {
    let app = XCUIApplication()
    app.launch()
    focusAndType(storyID, into: app.searchFields["Search stories and keywords"], in: app)
    let row = element("design-os.gallery.catalog.story.\(storyID)", in: app)
    XCTAssertTrue(row.waitForExistence(timeout: galleryUITestTimeout))
    row.tap()
    return app
  }

  @MainActor
  private func openInteractiveExample(in app: XCUIApplication) {
    let button = app.buttons["Open interactive example"]
    XCTAssertTrue(button.waitForExistence(timeout: galleryUITestTimeout))
    button.tap()
  }

  @MainActor
  private func focusAndType(_ text: String, into field: XCUIElement, in app: XCUIApplication) {
    XCTAssertTrue(field.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(field.isHittable)
    field.tap()
    XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: galleryUITestTimeout))
    field.typeText(text)
  }

  @MainActor
  private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }
}
