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
  func testNativeNavigationAdaptiveSplitViewSelectionAndTabsMode() {
    let app = launchStory("native.navigation-tabs-toolbars")
    XCTAssertTrue(
      element("design-os.gallery.story.native.navigation-tabs-toolbars.ready", in: app)
        .waitForExistence(timeout: galleryUITestTimeout)
    )
    openInteractiveExample(in: app)

    let favoritesRow = element("design-os.navigation.row.favorites", in: app)
    let libraryRow = element("design-os.navigation.row.library", in: app)
    let detailSelection = element("design-os.navigation.detail.selection", in: app)

    // Handle initial compact vs wide state:
    // If Library row is visible and hittable, tap it to inspect Library detail
    if libraryRow.waitForExistence(timeout: galleryUITestTimeout) && libraryRow.isHittable {
      libraryRow.tap()
    }
    XCTAssertTrue(detailSelection.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(app.staticTexts["Caller-owned selection state: Library"].exists)

    let libraryAttachment = XCTAttachment(screenshot: app.screenshot())
    libraryAttachment.name = "specimen-interactive-library"
    libraryAttachment.lifetime = .keepAlways
    add(libraryAttachment)

    // If Favorites row is not hittable (in compact mode showing detail), tap exact Adaptive Navigation back button
    if !favoritesRow.isHittable {
      let backButton = app.buttons["Adaptive Navigation"]
      if backButton.waitForExistence(timeout: galleryUITestTimeout) {
        backButton.tap()
      }
    }

    // Verify tabs mode switching within interactive specimen on the sidebar
    let tabsModeButton = app.buttons["Tabs"]
    if tabsModeButton.waitForExistence(timeout: galleryUITestTimeout) && tabsModeButton.isHittable {
      tabsModeButton.tap()
      let searchTab =
        app.tabBars.buttons["Search"].exists
        ? app.tabBars.buttons["Search"] : app.buttons["Search"]
      XCTAssertTrue(searchTab.waitForExistence(timeout: galleryUITestTimeout))
      let splitModeButton = app.buttons["Split View"]
      if splitModeButton.waitForExistence(timeout: galleryUITestTimeout)
        && splitModeButton.isHittable
      {
        splitModeButton.tap()
      }
    }

    XCTAssertTrue(favoritesRow.waitForExistence(timeout: galleryUITestTimeout))
    favoritesRow.tap()

    XCTAssertTrue(detailSelection.waitForExistence(timeout: galleryUITestTimeout))
    let favoritesDetail = app.staticTexts["Caller-owned selection state: Favorites"]
    XCTAssertTrue(favoritesDetail.waitForExistence(timeout: galleryUITestTimeout))

    // Verify useful exit via dismiss button
    let dismissButton = element("design-os.navigation.action.dismiss-preview", in: app)
    XCTAssertTrue(dismissButton.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(dismissButton.isHittable)
    dismissButton.tap()

    XCTAssertTrue(
      element("design-os.reference.native.navigation-tabs-toolbars.preview", in: app)
        .waitForExistence(timeout: galleryUITestTimeout)
    )
  }

  @MainActor
  func testNativeNavigationAdaptiveSplitViewRotationDiagnostics() {
    defer {
      XCUIDevice.shared.orientation = .portrait
    }

    let app = launchStory("native.navigation-tabs-toolbars")
    XCTAssertTrue(
      element("design-os.gallery.story.native.navigation-tabs-toolbars.ready", in: app)
        .waitForExistence(timeout: galleryUITestTimeout)
    )
    openInteractiveExample(in: app)

    let initialWindow = app.windows.firstMatch
    let initialFrame = initialWindow.frame
    XCTAssertTrue(initialFrame.height > initialFrame.width, "Initial phone frame must be portrait")

    let libraryRow = element("design-os.navigation.row.library", in: app)
    let detailSelection = element("design-os.navigation.detail.selection", in: app)
    if libraryRow.waitForExistence(timeout: galleryUITestTimeout) && libraryRow.isHittable {
      libraryRow.tap()
    }
    XCTAssertTrue(detailSelection.waitForExistence(timeout: galleryUITestTimeout))

    // Rotate to landscape and observe numeric active window geometry via typed predicate
    XCUIDevice.shared.orientation = .landscapeLeft
    let landscapeExpectation = XCTNSPredicateExpectation(
      predicate: NSPredicate { _, _ in
        let f = app.windows.firstMatch.frame
        return f.width > f.height
      },
      object: nil
    )
    let landscapeResult = XCTWaiter.wait(for: [landscapeExpectation], timeout: galleryUITestTimeout)
    let landscapeFrame = app.windows.firstMatch.frame

    // Capture real native screen screenshot after orientation transition
    let landscapeAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    landscapeAttachment.name = "diagnostic-native-screen-landscape"
    landscapeAttachment.lifetime = .keepAlways
    add(landscapeAttachment)

    // Verify detail selection survives landscape re-layout
    XCTAssertTrue(detailSelection.waitForExistence(timeout: galleryUITestTimeout))

    // Restore orientation to portrait and observe restored geometry via typed predicate
    XCUIDevice.shared.orientation = .portrait
    let portraitExpectation = XCTNSPredicateExpectation(
      predicate: NSPredicate { _, _ in
        let f = app.windows.firstMatch.frame
        return f.height > f.width
      },
      object: nil
    )
    let portraitResult = XCTWaiter.wait(for: [portraitExpectation], timeout: galleryUITestTimeout)
    let restoredFrame = app.windows.firstMatch.frame

    let portraitAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    portraitAttachment.name = "diagnostic-native-screen-portrait-restored"
    portraitAttachment.lifetime = .keepAlways
    add(portraitAttachment)

    // Numeric frame assertions on typed observations
    XCTAssertEqual(
      landscapeResult, .completed, "Typed geometry wait for landscape orientation must complete")
    XCTAssertTrue(
      landscapeFrame.width > landscapeFrame.height, "Observed landscape width must exceed height")
    XCTAssertEqual(
      portraitResult, .completed, "Typed geometry wait for restored portrait must complete")
    XCTAssertTrue(
      restoredFrame.height > restoredFrame.width, "Observed restored height must exceed width")

    // Verify exit via dismiss button
    let dismissButton = element("design-os.navigation.action.dismiss-preview", in: app)
    if dismissButton.waitForExistence(timeout: galleryUITestTimeout) && dismissButton.isHittable {
      dismissButton.tap()
    }
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
    for _ in 0..<12 where !button.isHittable {
      app.swipeUp()
    }
    button.tap()
    let dismissButton = element("design-os.navigation.action.dismiss-preview", in: app)
    XCTAssertTrue(dismissButton.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(dismissButton.isHittable)
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
