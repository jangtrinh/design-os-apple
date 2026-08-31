import XCTest

final class DesignOSAppleGalleryFoundationStoryUITests: XCTestCase {
  @MainActor
  func testFoundationStoriesExposeUsefulStorybookContent() {
    let stories = [
      "foundation.profile-customization",
      "foundation.color-roles",
      "foundation.platform-semantic-color",
      "foundation.typography",
    ]

    for (index, storyID) in stories.enumerated() {
      let app = launchStory(storyID)
      assertExists("design-os.storybook.\(storyID).preview", in: app)
      assertExists("design-os.storybook.\(storyID).code-content", in: app)
      assertExists("design-os.storybook.\(storyID).guidance.use-it-when", in: app)

      if index == 0 {
        let copyButton = element("design-os.storybook.\(storyID).copy", in: app)
        scrollUntilHittable(copyButton, in: app)
        copyButton.tap()
        XCTAssertEqual(
          element("design-os.storybook.\(storyID).copy", in: app).label,
          "Copied"
        )
      }
      app.terminate()
    }
  }

  @MainActor
  func testFoundationRoleRowsDoNotOverlap() {
    assertVerticalSeparation(
      storyID: "foundation.color-roles",
      firstID: "design-os.storybook.color-role.label-primary",
      secondID: "design-os.storybook.color-role.label-secondary"
    )
    assertVerticalSeparation(
      storyID: "foundation.typography",
      firstID: "design-os.storybook.typography.large-title",
      secondID: "design-os.storybook.typography.title"
    )
  }

  @MainActor
  private func launchStory(_ storyID: String) -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = ["--design-os-story", storyID]
    app.launch()
    return app
  }

  @MainActor
  private func assertExists(_ identifier: String, in app: XCUIApplication) {
    XCTAssertTrue(
      element(identifier, in: app).waitForExistence(timeout: galleryUITestTimeout),
      "Missing real Storybook content: \(identifier)"
    )
  }

  @MainActor
  private func assertVerticalSeparation(
    storyID: String,
    firstID: String,
    secondID: String
  ) {
    let app = launchStory(storyID)
    let first = element(firstID, in: app)
    let second = element(secondID, in: app)
    XCTAssertTrue(first.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertTrue(second.waitForExistence(timeout: galleryUITestTimeout))
    XCTAssertGreaterThanOrEqual(
      second.frame.minY,
      first.frame.maxY,
      "\(storyID) rows must have distinct vertical layout positions"
    )
    app.terminate()
  }

  @MainActor
  private func scrollUntilHittable(_ element: XCUIElement, in app: XCUIApplication) {
    for _ in 0..<6 where !element.isHittable {
      app.swipeUp()
    }
    XCTAssertTrue(element.isHittable)
  }

  @MainActor
  private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }
}
