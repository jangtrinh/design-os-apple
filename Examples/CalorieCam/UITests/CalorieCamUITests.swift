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

    /// Attach the rendered app, never a mock or reconstructed image. CI must run the test
    /// and retain its xcresult bundle before these become visual evidence.
    private func attachScreenshot(_ name: String, of app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testEmptyJournalAndCancelCapture() {
        let app = launch()
        guard app.staticTexts["No meals logged"].waitForExistence(timeout: 5) else {
            XCTFail("Expected the empty diary before capturing evidence.")
            return
        }
        attachScreenshot("01-empty-diary", of: app)
        app.buttons["addMeal"].tap()
        guard app.staticTexts["On-device demo"].waitForExistence(timeout: 5) else {
            XCTFail("Expected the capture screen before capturing evidence.")
            return
        }
        XCTAssertFalse(app.buttons["demoEstimate"].isEnabled)
        attachScreenshot("02-capture-photo-choices", of: app)
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
        guard save.isEnabled else {
            XCTFail("Expected a valid editable meal before capturing evidence.")
            return
        }
        attachScreenshot("03-editable-meal-review", of: app)
        save.tap()
        guard app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Test apple")).firstMatch.waitForExistence(timeout: 5) else {
            XCTFail("Expected the saved diary entry before capturing evidence.")
            return
        }
        attachScreenshot("04-saved-diary", of: app)
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
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("Unsaved portion")
        let cancel = app.buttons["cancelMeal"]
        cancel.tap()
        let discard = app.buttons["Discard meal"]
        guard discard.waitForExistence(timeout: 5) else {
            XCTFail("Leaving an unfinished meal must offer explicit discard confirmation.")
            return
        }
        attachScreenshot("06-discard-confirmation", of: app)

        let keepEditing = app.buttons["Keep editing"]
        if keepEditing.exists && keepEditing.isHittable {
            keepEditing.tap()
        } else {
            // SwiftUI omits the cancel-role button in a native popover. Preserve that
            // platform behavior: Escape on Mac, or an outside tap on the iOS toolbar
            // anchor. Never tap a destructive action as a dismissal fallback.
            #if os(macOS)
            app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
            #else
            cancel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            #endif
        }
        let dialogDismissed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: discard)
        guard XCTWaiter.wait(for: [dialogDismissed], timeout: 5) == .completed else {
            XCTFail("Native cancellation did not dismiss the discard confirmation.")
            return
        }
        XCTAssertTrue(app.textFields["foodName"].exists)
        XCTAssertEqual(portion.value as? String, "Unsaved portion", "Cancelling discard must preserve the draft.")
        attachScreenshot("07-draft-preserved-after-cancel", of: app)

        // Confirm the separate destructive path still requires the explicit button.
        cancel.tap()
        guard discard.waitForExistence(timeout: 5) else {
            XCTFail("Expected discard confirmation again before removing the draft.")
            return
        }
        discard.tap()
        let reviewClosed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.textFields["foodName"])
        XCTAssertEqual(XCTWaiter.wait(for: [reviewClosed], timeout: 5), .completed)
        XCTAssertTrue(app.staticTexts["No meals logged"].waitForExistence(timeout: 5))
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

    func testOutOfRangeCaloriesBlockSaving() {
        let app = launch()
        app.buttons["addMeal"].tap()
        app.buttons["enterManually"].tap()
        let name = app.textFields["foodName"]
        guard name.waitForExistence(timeout: 5) else {
            XCTFail("Expected manual meal review.")
            return
        }
        name.tap()
        name.typeText("Test food")
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("1 serving")
        let save = app.buttons["saveMeal"]
        let valid = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: save)
        guard XCTWaiter.wait(for: [valid], timeout: 5) == .completed else {
            XCTFail("The named, portioned zero-calorie entry was not valid before editing.")
            return
        }
        let calories = app.textFields["foodCalories"]
        calories.tap()
        // Digits work with both the iOS decimal keyboard and the Mac keyboard. Whether
        // inserted before or after the initial zero, this exceeds the 10,000 kcal limit.
        calories.typeText("100001")
        let blocked = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == false"), object: save)
        guard XCTWaiter.wait(for: [blocked], timeout: 5) == .completed else {
            XCTFail("Save remained enabled after entering out-of-range calories.")
            return
        }
        attachScreenshot("05-invalid-calorie-review", of: app)
        XCTAssertFalse(save.isEnabled, "Invalid calories must not save a previous valid value.")
    }

}
