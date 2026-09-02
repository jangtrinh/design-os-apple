import XCTest

final class DesignOSAppleGalleryLocalDemoUITests: XCTestCase {
  @MainActor
  func testFlightTripFilterOpensOnlyFromItsChevronControl() {
    let app = launchMiniApps()
    let flow = MiniAppFlow.all[2]
    open(flow.cardID, expecting: flow.entryID, in: app)

    let panel = element(
      "design-os.demo.mobility.flight-tracker.trip-filter-panel", in: app)
    let toggle = element(
      "design-os.demo.mobility.flight-tracker.trip-filter-toggle", in: app)
    XCTAssertFalse(panel.exists)
    element("design-os.demo.mobility.flight-tracker.trip-list-title", in: app).tap()
    XCTAssertFalse(panel.exists)
    toggle.tap()
    XCTAssertTrue(panel.waitForExistence(timeout: galleryUITestTimeout))
    element("design-os.demo.mobility.flight-tracker.filter.sharedTrips", in: app).tap()
    XCTAssertFalse(app.staticTexts["Oslo to Lisbon"].exists)
    XCTAssertTrue(
      app.staticTexts["Dallas to Dubai"].waitForExistence(timeout: galleryUITestTimeout))
  }

  @MainActor
  func testStreamingLibrarySecondStateIsReachedByScrollingTheSamePage() {
    let app = launchMiniApps()
    let flow = MiniAppFlow.all[4]
    open(flow.cardID, expecting: flow.entryID, in: app)
    reachSecondState(for: flow, in: app)
    assertReady("design-os.demo.entertainment.streaming-library.page", in: app)
    nativeBack(in: app).tap()
    assertReady("design-os.gallery.examples.ready", in: app)
  }

  @MainActor
  func testRepresentativeControlsChangeContentOrCompleteTheirAction() {
    let app = launchMiniApps()

    let visual = MiniAppFlow.all[1]
    open(visual.cardID, expecting: visual.entryID, in: app)
    tapWhenHittable(element(visual.transitionID!, in: app), in: app)
    assertReady(visual.detailID, in: app)
    element("design-os.demo.assistant.visual.regenerate", in: app).tap()
    XCTAssertTrue(
      element("design-os.demo.assistant.visual.closing-question", in: app)
        .label.contains("Revision 1"))
    element("design-os.demo.assistant.visual.copy", in: app).tap()
    XCTAssertTrue(app.alerts["Answer copied"].waitForExistence(timeout: galleryUITestTimeout))
    app.alerts.buttons["Done"].tap()
    nativeBack(in: app).tap()
    nativeBack(in: app).tap()
    assertReady("design-os.gallery.examples.ready", in: app)

    let streaming = MiniAppFlow.all[4]
    open(streaming.cardID, expecting: streaming.entryID, in: app)
    element("design-os.demo.entertainment.streaming-library.tab.newAndHot", in: app).tap()
    assertReady(
      "design-os.demo.entertainment.streaming-library.tab-state.newAndHot", in: app)
    XCTAssertTrue(
      app.staticTexts["Trending this week"].waitForExistence(timeout: galleryUITestTimeout))
  }

  @MainActor
  func testEveryMiniAppReachesItsSecondStateAndReturnsWithNativeBack() {
    let app = launchMiniApps()
    exerciseEveryMiniApp(appearance: "light", app: app)
  }

  @MainActor
  func testEveryMiniAppSupportsDarkAppearanceAndReturnsWithNativeBack() {
    let app = launchMiniApps(appearance: "Dark")
    exerciseEveryMiniApp(appearance: "dark", app: app)
  }

  @MainActor
  private func exerciseEveryMiniApp(appearance: String, app: XCUIApplication) {
    capture("local-demo-\(appearance)-00-mini-apps", app: app)
    for (index, flow) in MiniAppFlow.all.enumerated() {
      open(flow.cardID, expecting: flow.entryID, in: app)
      capture(
        "local-demo-\(appearance)-\(String(format: "%02d", index * 2 + 1))-\(flow.slug)-entry",
        app: app
      )

      if let preparationID = flow.preparationID {
        tapWhenHittable(element(preparationID, in: app), in: app)
      }
      reachSecondState(for: flow, in: app)
      capture(
        "local-demo-\(appearance)-\(String(format: "%02d", index * 2 + 2))-\(flow.slug)-detail",
        app: app
      )

      if !flow.usesScrollTransition {
        nativeBack(in: app).tap()
        assertReady(flow.entryID, in: app)
      }
      nativeBack(in: app).tap()
      assertReady("design-os.gallery.examples.ready", in: app)
    }
  }
}
