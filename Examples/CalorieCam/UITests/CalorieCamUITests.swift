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

    /// A native NavigationLink is exposed as a Button in the macOS outline, while
    /// the iOS combined row exposes its text. Assert the actual platform semantics.
    private func savedMeal(named name: String, in app: XCUIApplication) -> XCUIElement {
        let matchingName = NSPredicate(format: "label CONTAINS %@", name)
        #if os(macOS)
        return app.windows.buttons.containing(matchingName).firstMatch
        #else
        return app.staticTexts.containing(matchingName).firstMatch
        #endif
    }

    /// The photo-led capture screen scrolls on smaller windows; let the native
    /// ScrollView reveal the action instead of assuming every button is above the fold.
    private func tapCaptureAction(_ identifier: String, in app: XCUIApplication) -> Bool {
        let action = app.buttons[identifier]
        guard action.waitForExistence(timeout: 5) else {
            XCTFail("Missing capture action: \(identifier)")
            return false
        }
        let scroll = app.descendants(matching: .any).matching(identifier: "mealCaptureScroll").firstMatch
        for _ in 0..<5 {
            if action.isHittable { action.tap(); return true }
            scroll.swipeUp()
        }
        XCTFail("Capture action did not become reachable by scrolling: \(identifier)")
        return false
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
        XCTAssertFalse(app.buttons["demoEstimate"].exists)
        XCTAssertTrue(app.buttons["trySampleMeal"].exists)
        attachScreenshot("02-capture-photo-choices", of: app)
        app.buttons["cancelMeal"].tap()
        XCTAssertTrue(app.staticTexts["No meals logged"].waitForExistence(timeout: 5))
    }

    func testManualMealSaveAndPersistence() {
        let id = UUID().uuidString
        let app = launch(journalID: id)
        app.buttons["addMeal"].tap()
        guard tapCaptureAction("enterManually", in: app) else { return }
        let name = app.textFields["foodName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Test apple")
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("1 medium")
        let calories = app.textFields["foodCalories"]
        #if os(macOS)
        calories.tap()
        app.typeKey("a", modifierFlags: .command)
        #else
        // The initial value is one numeric token. Double-tap selects it instead of
        // assuming where a single tap placed the insertion cursor.
        calories.doubleTap()
        #endif
        calories.typeText("95")
        guard calories.value as? String == "95" else {
            XCTFail("Calorie replacement failed; expected exactly 95 before saving or capturing evidence.")
            return
        }
        let save = app.buttons["saveMeal"]
        #if os(iOS)
        let done = app.buttons["finishFoodEditing"]
        guard done.waitForExistence(timeout: 5) else {
            XCTFail("Expected the native keyboard Done action.")
            return
        }
        done.tap()
        let keyboardClosed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.keyboards.firstMatch)
        guard XCTWaiter.wait(for: [keyboardClosed], timeout: 5) == .completed else {
            XCTFail("Done did not dismiss the editing keyboard.")
            return
        }
        let form = app.descendants(matching: .any).matching(identifier: "mealReviewForm").firstMatch
        for _ in 0..<3 {
            if app.staticTexts["Manually entered"].isHittable { break }
            form.swipeDown()
        }
        guard name.isHittable else {
            XCTFail("The review screenshot must show the food name.")
            return
        }
        #endif
        guard save.isEnabled else {
            XCTFail("Expected a valid editable meal before capturing evidence.")
            return
        }
        attachScreenshot("03-editable-meal-review", of: app)
        save.tap()
        let reviewClosed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: name)
        guard XCTWaiter.wait(for: [reviewClosed], timeout: 5) == .completed else {
            XCTFail("Saving did not close the editable review.")
            return
        }
        let row = savedMeal(named: "Test apple", in: app)
        guard row.waitForExistence(timeout: 5) else {
            XCTFail("Expected the saved diary entry before capturing evidence.")
            return
        }
        guard row.label.contains("95 kcal") else {
            XCTFail("The saved row does not contain the reviewed 95 kcal value.")
            return
        }
        attachScreenshot("04-saved-diary", of: app)
        app.terminate()
        let reopened = launch(journalID: id)
        let persistedRow = savedMeal(named: "Test apple", in: reopened)
        guard persistedRow.waitForExistence(timeout: 5),
              persistedRow.label.contains("95 kcal"),
              persistedRow.label.contains("Manually entered") else {
            XCTFail("The reviewed meal, exact calorie value and provenance must survive relaunch.")
            return
        }
        persistedRow.tap()
        let detailName = reopened.staticTexts["mealDetailFoodName"]
        guard detailName.waitForExistence(timeout: 5) else {
            XCTFail("Selecting the saved row did not open meal details.")
            return
        }
        let detailPortion = reopened.staticTexts["mealDetailPortion"]
        let detailCalories = reopened.staticTexts["mealDetailCalories"]
        // AppKit exposes ordinary Text through value, while UIKit uses label.
        guard (detailName.value as? String ?? detailName.label) == "Test apple",
              (detailPortion.value as? String ?? detailPortion.label) == "1 medium",
              (detailCalories.value as? String ?? detailCalories.label) == "95 kcal" else {
            XCTFail("Meal details must show the persisted name, portion and exact calorie value.")
            return
        }
        attachScreenshot("08-meal-detail", of: reopened)
    }

    func testBlankMealCannotBeSavedAndDiscardNeedsConfirmation() {
        let app = launch()
        app.buttons["addMeal"].tap()
        guard tapCaptureAction("enterManually", in: app) else { return }
        XCTAssertFalse(app.buttons["saveMeal"].isEnabled)
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("Unsaved portion")
        let cancel = app.buttons["cancelMeal"]
        cancel.tap()
        #if os(macOS)
        // App-wide queries also find the native Touch Bar's mirrored action.
        let discard = app.windows.buttons["Discard meal"]
        #else
        let discard = app.buttons["Discard meal"]
        #endif
        guard discard.waitForExistence(timeout: 5) else {
            XCTFail("Leaving an unfinished meal must offer explicit discard confirmation.")
            return
        }
        attachScreenshot("06-discard-confirmation", of: app)

        #if os(macOS)
        let keepEditing = app.windows.buttons["Keep editing"]
        #else
        let keepEditing = app.buttons["Keep editing"]
        #endif
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
        guard tapCaptureAction("enterManually", in: app) else { return }
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

    func testSamplePhotoReviewKeepsDemoProvenance() {
        let app = launch()
        app.buttons["addMeal"].tap()
        guard tapCaptureAction("trySampleMeal", in: app) else { return }
        guard app.staticTexts["Demo · sample numbers"].waitForExistence(timeout: 5),
              app.images["Meal photo, for your reference only"].exists else {
            XCTFail("Sample review must show its photo and explicit demo provenance.")
            return
        }
        let save = app.buttons["saveMeal"]
        guard save.isEnabled else {
            XCTFail("Expected the valid, clearly labeled sample to be reviewable before saving.")
            return
        }
        attachScreenshot("09-sample-photo-review", of: app)

        // Deliberately activate Save in this isolated test journal. The sample path
        // itself must never save automatically or send a network request.
        save.tap()
        let reviewClosed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: app.textFields.matching(identifier: "foodName").firstMatch
        )
        guard XCTWaiter.wait(for: [reviewClosed], timeout: 5) == .completed else {
            XCTFail("Explicit sample Save did not close review.")
            return
        }
        // Match a stable title fragment rather than its visual wrapping into two lines.
        let sampleRow = savedMeal(named: "Example rice", in: app)
        guard sampleRow.waitForExistence(timeout: 5),
              sampleRow.label.contains("Example chicken"),
              sampleRow.label.contains("430 kcal"),
              sampleRow.label.contains("Demo · sample numbers") else {
            XCTFail("The saved sample must retain its fixture foods, 430 kcal and explicit demo provenance.")
            return
        }
        attachScreenshot("10-sample-diary", of: app)
    }

}
