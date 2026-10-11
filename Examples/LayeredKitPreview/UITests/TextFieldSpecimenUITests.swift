import XCTest

@MainActor
final class TextFieldSpecimenUITests: XCTestCase {
    private func launch(state: String, appearance: String = "light") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["LAYERED_KIT_SPECIMEN"] = "text-fields"
        app.launchEnvironment["LAYERED_KIT_FIELD_STATE"] = state
        app.launchEnvironment["LAYERED_KIT_APPEARANCE"] = appearance
        app.launch()
        return app
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testTextFieldReferenceStates() {
        for appearance in ["light", "dark"] {
            for state in ["normal", "focused", "disabled", "error", "secure", "multiline", "nested"] {
                let app = launch(state: state, appearance: appearance)
                let identifier: String
                switch state {
                case "secure": identifier = "fieldSecure"
                case "multiline": identifier = "fieldMultiline"
                case "nested": identifier = "fieldNested"
                default: identifier = "fieldSingleLine"
                }
                let field = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
                XCTAssertTrue(field.waitForExistence(timeout: 10))
                XCTAssertEqual(field.isEnabled, state != "disabled")
                if state == "error" {
                    XCTAssertTrue(app.staticTexts["fieldValidation"].exists)
                }
                if state == "secure" {
                    XCTAssertTrue(app.secureTextFields["fieldSecure"].exists)
                }
                if state == "focused" {
                    field.tap()
                    #if os(iOS)
                    XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
                    #endif
                }
                capture("text-field-\(state)-\(appearance)", app: app)
                app.terminate()
            }
        }
    }

    func testFieldRetainsEditingAndFocus() {
        let app = launch(state: "normal")
        let field = app.textFields["fieldSingleLine"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText(" local")
        XCTAssertTrue((field.value as? String)?.contains("local") == true)
        app.buttons["fieldFinishEditing"].tap()
        #if os(iOS)
        let keyboardDismissed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"), object: app.keyboards.firstMatch)
        XCTAssertEqual(XCTWaiter.wait(for: [keyboardDismissed], timeout: 5), .completed)
        #endif
        field.tap()
        field.typeText(" again")
        XCTAssertTrue((field.value as? String)?.contains("again") == true)
    }

    func testSecureFieldKeepsNativeSecureEntry() {
        let app = launch(state: "secure")
        let field = app.secureTextFields["fieldSecure"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        let fixtureText = "fixture-only"
        field.typeText(fixtureText)
        let entered = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label == %@", "Text entered"),
            object: app.staticTexts["fieldSecureStatus"])
        XCTAssertEqual(XCTWaiter.wait(for: [entered], timeout: 5), .completed,
                       "Native typing must update the caller-owned secure binding")
        XCTAssertTrue(field.exists, "The edited control must remain a native secure text field")
        // XCUI value is optional raw Accessibility data; do not assume a platform's masking glyph.
        // Binding-state evidence above prevents nil, empty or unchanged AX values from faking editing.
        let exposesPlaintext = (field.value as? String) == fixtureText
        XCTAssertFalse(exposesPlaintext, "Secure Accessibility value must not expose entered content")
        // Deliberately no screenshot or accessibility dump after secure text entry.
    }
}
