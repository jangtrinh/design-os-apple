import XCTest

/// Run against both schemes on Apple tooling. Each test uses an isolated journal.
@MainActor
final class CalorieCamUITests: XCTestCase {
    private func launch(journalID: String = UUID().uuidString) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["CALORIECAM_TEST_JOURNAL"] = journalID
        app.launchEnvironment["CALORIECAM_ANALYSIS_URL"] = ""
        app.launch()
        return app
    }

    func testEmptyJournalAndCancelCapture() {
        let app = launch()
        XCTAssertTrue(app.staticTexts["No meals logged"].waitForExistence(timeout: 5))
        app.buttons["addMeal"].tap()
        XCTAssertTrue(app.staticTexts["On-device demo"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["demoEstimate"].isEnabled)
        app.buttons["cancelMeal"].tap()
        XCTAssertTrue(app.staticTexts["No meals logged"].waitForExistence(timeout: 5))
    }

    func testManualMealSaveAndPersistence() {
        let id = UUID().uuidString
        let app = launch(journalID: id)
        app.buttons["addMeal"].tap()
        app.buttons["enterManually"].tap()
        let name = app.textFields["foodName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Test apple")
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("1 medium")
        let calories = app.textFields["foodCalories"]
        calories.tap()
        // Initial value is 0. Appending 95 yields 095, which is a valid number.
        calories.typeText("95")
        let save = app.buttons["saveMeal"]
        #if os(iOS)
        if !save.isHittable { app.swipeUp() }
        #endif
        XCTAssertTrue(save.isEnabled)
        save.tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Test apple")).firstMatch.waitForExistence(timeout: 5))
        app.terminate()
        let reopened = launch(journalID: id)
        XCTAssertTrue(reopened.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Test apple")).firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(reopened.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Manually entered")).firstMatch.exists)
    }

    func testBlankMealCannotBeSavedAndDiscardNeedsConfirmation() {
        let app = launch()
        app.buttons["addMeal"].tap()
        app.buttons["enterManually"].tap()
        XCTAssertFalse(app.buttons["saveMeal"].isEnabled)
        app.buttons["cancelMeal"].tap()
        XCTAssertTrue(app.buttons["Discard meal"].waitForExistence(timeout: 5))
        app.buttons["Keep editing"].tap()
        XCTAssertTrue(app.textFields["foodName"].exists)
    }

    func testConfiguredAIRequiresPhotoBeforeUploadAction() {
        let app = XCUIApplication()
        app.launchEnvironment["CALORIECAM_TEST_JOURNAL"] = UUID().uuidString
        app.launchEnvironment["CALORIECAM_ANALYSIS_URL"] = "https://example.com/analyze"
        app.launch()
        app.buttons["addMeal"].tap()
        XCTAssertTrue(app.staticTexts["Photo meal entry"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["remoteEstimate"].exists)
        XCTAssertFalse(app.buttons["remoteEstimate"].isEnabled)
        app.buttons["cancelMeal"].tap()
    }

}
