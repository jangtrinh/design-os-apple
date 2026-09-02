import XCTest

final class DesignOSAppleGalleryDesignFloorUITests: XCTestCase {
  @MainActor
  func testEveryStoryFirstViewportRendersInCurrentEnvironment() throws {
    for storyID in try storyIDs() {
      let app = launchStory(storyID)
      XCTAssertTrue(
        element("design-os.gallery.story.\(storyID).ready", in: app)
          .waitForExistence(timeout: galleryUITestTimeout),
        "Missing \(storyID)"
      )
      capture("story-\(storyID)", app: app)
      app.terminate()
    }
  }

  @MainActor
  func testCatalogDiscoveryStatesRenderInCurrentEnvironment() {
    let catalog = launchCatalog()
    capture("catalog-base", app: catalog)

    let searchField = catalog.searchFields["Search stories and keywords"]
    focusAndType("component.list-row", into: searchField, in: catalog)
    XCTAssertTrue(
      element("design-os.gallery.catalog.story.component.list-row", in: catalog)
        .waitForExistence(timeout: galleryUITestTimeout)
    )
    dismissKeyboard(in: catalog)
    capture("catalog-search", app: catalog)
    catalog.terminate()

    let noResults = launchCatalog()
    focusAndType(
      "not-an-admitted-story",
      into: noResults.searchFields["Search stories and keywords"],
      in: noResults
    )
    XCTAssertTrue(
      noResults.descendants(matching: .any)
        .matching(NSPredicate(format: "label CONTAINS[c] %@", "No Results"))
        .firstMatch.waitForExistence(timeout: galleryUITestTimeout)
    )
    dismissKeyboard(in: noResults)
    capture("catalog-no-results", app: noResults)
    noResults.terminate()
  }

  @MainActor
  func testAccessibilityLayoutsKeepCatalogAndRepresentativeDetailsUsable() {
    let catalog = launchCatalog()
    capture("catalog-accessibility-xxxl", app: catalog)
    catalog.terminate()

    for storyID in [
      "component.list-row",
      "native.home-screen-quick-actions",
      "foundation.profile-customization",
      "primitive.accessory-slot-layout",
      "native.content-unavailable",
      "omniact.settings-shell",
    ] {
      let app = launchStory(storyID)
      XCTAssertTrue(
        element("design-os.gallery.story.\(storyID).ready", in: app)
          .waitForExistence(timeout: galleryUITestTimeout)
      )
      let copyKeyword = element("design-os.reference.\(storyID).copy-keyword", in: app)
      XCTAssertTrue(copyKeyword.waitForExistence(timeout: galleryUITestTimeout))
      XCTAssertGreaterThanOrEqual(copyKeyword.frame.width, 44)
      XCTAssertGreaterThanOrEqual(copyKeyword.frame.height, 44)
      capture("story-\(storyID)-accessibility-xxxl", app: app)

      scrollUntilHittable(copyKeyword, in: app)
      copyKeyword.tap()

      let copyCode = app.buttons["Copy code"]
      scrollUntilHittable(copyCode, in: app)
      copyCode.tap()
      scrollUntilVisible(app.staticTexts["Contract"], in: app)
      scrollUntilVisible(app.staticTexts["Continue"], in: app)

      if storyID == "component.list-row" {
        let relatedStory = app.buttons["Sidebar row"]
        scrollUntilHittable(relatedStory, in: app)
        relatedStory.tap()
        XCTAssertTrue(
          element("design-os.gallery.story.component.sidebar-row.ready", in: app)
            .waitForExistence(timeout: galleryUITestTimeout)
        )
      }
      app.terminate()
    }
  }
  @MainActor
  func testDestinationStoryReferenceAndInteractiveExampleRenderInCurrentEnvironment() {
    let app = launchStory("foundation.profile-customization")
    XCTAssertTrue(
      element("design-os.gallery.story.foundation.profile-customization.ready", in: app)
        .waitForExistence(timeout: galleryUITestTimeout)
    )
    capture("destination-story-profile-customization-reference", app: app)

    let openExample = app.buttons["Open interactive example"]
    scrollUntilHittable(openExample, in: app)
    openExample.tap()
    XCTAssertTrue(
      element("design-os.gallery.story.foundation.profile-customization.ready", in: app)
        .waitForExistence(timeout: galleryUITestTimeout)
    )
    XCTAssertTrue(openExample.waitForNonExistence(timeout: galleryUITestTimeout))
    capture("destination-story-profile-customization-interactive", app: app)
  }
  @MainActor
  private func launchCatalog() -> XCUIApplication {
    launch(storyID: nil)
  }
  @MainActor
  private func launchStory(_ storyID: String) -> XCUIApplication {
    launch(storyID: storyID)
  }

  @MainActor
  private func launch(storyID: String?) -> XCUIApplication {
    XCUIDevice.shared.orientation = .portrait
    let app = XCUIApplication()
    if let storyID { app.launchArguments += ["--design-os-story", storyID] }
    app.launch()
    return app
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
  private func dismissKeyboard(in app: XCUIApplication) {
    for label in ["Search", "search", "Done", "done"] {
      let button = app.keyboards.buttons[label]
      if button.exists {
        button.tap()
        return
      }
    }
  }

  @MainActor
  private func scrollUntilHittable(_ target: XCUIElement, in app: XCUIApplication) {
    for _ in 0..<12 where !target.isHittable {
      app.swipeUp()
    }
    XCTAssertTrue(target.isHittable)
  }

  @MainActor
  private func scrollUntilVisible(_ target: XCUIElement, in app: XCUIApplication) {
    for _ in 0..<12 where !isVisible(target, in: app) {
      app.swipeUp()
    }
    XCTAssertTrue(isVisible(target, in: app))
  }

  @MainActor
  private func isVisible(_ target: XCUIElement, in app: XCUIApplication) -> Bool {
    target.exists && !target.frame.isEmpty && target.frame.intersects(app.frame)
  }

  @MainActor
  private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }

  @MainActor
  private func capture(_ name: String, app: XCUIApplication) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func storyIDs() throws -> [String] {
    let bundleURL =
      URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("Generated/design-os-apple-catalog-bundle.v2.json")
    let envelope = try JSONDecoder().decode(
      CatalogBundleEnvelope.self,
      from: Data(contentsOf: bundleURL)
    )
    return envelope.schema.storyIDs
  }
}

private struct CatalogBundleEnvelope: Decodable {
  struct Schema: Decodable {
    let storyIDs: [String]
  }

  let schema: Schema
}
