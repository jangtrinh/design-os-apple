import XCTest

let galleryUITestTimeout: TimeInterval = 5

final class DesignOSAppleGalleryUITests: XCTestCase {
  @MainActor
  func testDefaultLaunchShowsCatalogWithoutDebugText() {
    let app = XCUIApplication()
    app.launch()

    XCTAssertTrue(
      element("design-os.gallery.catalog.ready", in: app).waitForExistence(
        timeout: galleryUITestTimeout))
    XCTAssertFalse(app.staticTexts["Catalog ready"].exists)
  }

  @MainActor
  func testCatalogSearchOpensDictionaryStoryAndReturnsToCatalog() {
    let app = XCUIApplication()
    app.launch()

    let searchField = app.searchFields["Search admitted stories"]
    focusAndType("tocchien.dictionary-search", into: searchField, in: app)

    let dictionaryRow = element(
      "design-os.gallery.catalog.story.tocchien.dictionary-search", in: app)
    XCTAssertTrue(dictionaryRow.waitForExistence(timeout: galleryUITestTimeout))
    dictionaryRow.tap()

    let storyCanvas = element("design-os.gallery.story.tocchien.dictionary-search.ready", in: app)
    XCTAssertTrue(storyCanvas.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertFalse(app.staticTexts["Story ready"].exists)

    let catalogBackButton = app.navigationBars.buttons["Catalog"]
    XCTAssertEqual(app.navigationBars.buttons.matching(identifier: "Catalog").count, 1)
    XCTAssertTrue(catalogBackButton.waitForExistence(timeout: galleryUITestTimeout))
    catalogBackButton.tap()
    XCTAssertTrue(storyCanvas.waitForNonExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(
      element("design-os.gallery.catalog.ready", in: app).waitForExistence(
        timeout: galleryUITestTimeout))
  }

  @MainActor
  func testCatalogSearchShowsNativeNoResults() {
    let app = XCUIApplication()
    app.launch()

    let searchField = app.searchFields["Search admitted stories"]
    focusAndType("not-an-admitted-story", into: searchField, in: app)

    let noResults = app.descendants(matching: .any)
      .matching(NSPredicate(format: "label CONTAINS[c] %@", "No Results"))
      .firstMatch
    XCTAssertTrue(noResults.waitForExistence(timeout: galleryUITestTimeout))
  }

  @MainActor
  func testSettingsStoryKeepsOneUsableGalleryBackPath() {
    let app = XCUIApplication()
    app.launch()

    let searchField = app.searchFields["Search admitted stories"]
    focusAndType("omniact.settings-shell", into: searchField, in: app)
    let settingsRow = element("design-os.gallery.catalog.story.omniact.settings-shell", in: app)
    XCTAssertTrue(settingsRow.waitForExistence(timeout: galleryUITestTimeout))
    settingsRow.tap()

    let storyCanvas = element("design-os.gallery.story.omniact.settings-shell.ready", in: app)
    XCTAssertTrue(storyCanvas.waitForExistence(timeout: galleryUITestTimeout))
    let catalogBackButton = app.navigationBars.buttons["Catalog"]
    XCTAssertEqual(app.navigationBars.buttons.matching(identifier: "Catalog").count, 1)
    XCTAssertTrue(catalogBackButton.waitForExistence(timeout: galleryUITestTimeout))
    catalogBackButton.tap()
    XCTAssertTrue(storyCanvas.waitForNonExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(
      element("design-os.gallery.catalog.ready", in: app).waitForExistence(
        timeout: galleryUITestTimeout))
  }

  @MainActor
  func testAdmittedTocChienDictionaryStoryLaunchesReady() {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", "tocchien.dictionary-search"]
    app.launch()

    XCTAssertTrue(
      element("design-os.gallery.story.tocchien.dictionary-search.ready", in: app)
        .waitForExistence(timeout: galleryUITestTimeout)
    )
    XCTAssertFalse(app.staticTexts["Story ready"].exists)
  }

  @MainActor
  func testCriticalGalleryStatesPassStructuralAccessibilityAudit() throws {
    let app = XCUIApplication()
    let auditTypes: XCUIAccessibilityAuditType = [
      .elementDetection,
      .hitRegion,
      .sufficientElementDescription,
      .trait,
    ]
    app.launch()

    try app.performAccessibilityAudit(for: auditTypes)

    if !app.buttons["Components"].exists {
      app.navigationBars.buttons.firstMatch.tap()
    }

    app.buttons["Components"].tap()
    XCTAssertTrue(app.buttons["List row"].waitForExistence(timeout: galleryUITestTimeout))
    try app.performAccessibilityAudit(for: auditTypes)

    app.buttons["List row"].tap()
    XCTAssertTrue(app.staticTexts["Project brief"].waitForExistence(timeout: galleryUITestTimeout))
    try app.performAccessibilityAudit(for: auditTypes)
  }

  @MainActor
  private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }

  @MainActor
  private func focusAndType(_ text: String, into field: XCUIElement, in app: XCUIApplication) {
    XCTAssertTrue(field.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(field.isHittable)
    field.tap()
    XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: galleryUITestTimeout))
    field.typeText(text)
  }
}
