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

    /// Only used by the nonsecure focused reference. Never call after secure entry.
    private func attachFocusedFieldDiagnostics(_ name: String, field: XCUIElement, app: XCUIApplication) {
        capture(name, app: app)
        var facts = ["appState=\(app.state.rawValue)", "fieldExists=\(field.exists)"]
        if field.exists {
            facts.append("fieldFrame=\(field.frame) enabled=\(field.isEnabled) hittable=\(field.isHittable)")
        }
        let attachment = XCTAttachment(string: facts.joined(separator: "\n") + "\n\n" + app.debugDescription)
        attachment.name = name + "-accessibility"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func focusReferenceField(_ field: XCUIElement, appearance: String, app: XCUIApplication) -> Bool {
        guard app.wait(for: .runningForeground, timeout: 5) else {
            attachFocusedFieldDiagnostics("failure-field-foreground-\(appearance)", field: field, app: app)
            XCTFail("The focused reference app must be foreground before its one native field tap.")
            return false
        }
        let ready = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND enabled == true AND hittable == true"),
            object: field)
        guard XCTWaiter.wait(for: [ready], timeout: 5) == .completed,
              app.state == .runningForeground else {
            attachFocusedFieldDiagnostics("failure-field-readiness-\(appearance)", field: field, app: app)
            XCTFail("The focused reference field must be enabled and hittable in the foreground app.")
            return false
        }
        // Readiness is a precondition, not proof of focus. The observed iPad miss
        // remains unexplained; retain before/after evidence and never retry its tap.
        attachFocusedFieldDiagnostics("before-field-focus-\(appearance)", field: field, app: app)
        field.tap()
        #if os(iOS)
        let keyboardAppeared = app.keyboards.firstMatch.waitForExistence(timeout: 5)
        if !keyboardAppeared {
            attachFocusedFieldDiagnostics("failure-field-focus-\(appearance)", field: field, app: app)
        }
        XCTAssertTrue(keyboardAppeared, "One native field tap must show the keyboard before a focused reference is captured.")
        return keyboardAppeared
        #else
        return true
        #endif
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
                    guard focusReferenceField(field, appearance: appearance, app: app) else {
                        app.terminate()
                        continue
                    }
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
        let status = app.staticTexts["fieldSecureStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        // AppKit exposes this native StaticText's displayed content through AX value;
        // UIKit exposes it through label. Check the actual binding transition on each.
        #if os(macOS)
        let statusAttribute = "value"
        #else
        let statusAttribute = "label"
        #endif
        let initiallyEmpty = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "%K == %@", statusAttribute, "No text entered"),
            object: status)
        XCTAssertEqual(XCTWaiter.wait(for: [initiallyEmpty], timeout: 5), .completed,
                       "The caller-owned secure binding must start empty")
        field.tap()
        let fixtureText = "fixture-only"
        field.typeText(fixtureText)
        let entered = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "%K == %@", statusAttribute, "Text entered"),
            object: status)
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
