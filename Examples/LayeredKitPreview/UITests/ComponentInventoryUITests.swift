import XCTest

/// Separate class so CI can shard isolated components independently from 18 screen-family tests.
@MainActor
final class ComponentInventoryUITests: XCTestCase {
    private func capture(_ id: String, state: String = "default", appearance: String) throws {
        continueAfterFailure = false
        executionTimeAllowance = 600
        let app = XCUIApplication()
        app.launchEnvironment["LAYERED_KIT_COMPONENT"] = id
        app.launchEnvironment["LAYERED_KIT_COMPONENT_STATE"] = state
        app.launchEnvironment["LAYERED_KIT_APPEARANCE"] = appearance
        app.launch()
        defer { app.terminate() }
        let ready = app.staticTexts["component-ready-" + id].firstMatch
        XCTAssertTrue(ready.waitForExistence(timeout: 10), "Exact component route must render before capture: \(id)")
        XCTAssertTrue(ready.isHittable, "Fixture heading must be visible in the native window")
        if state == "sheet-open" {
            let open = app.buttons["inventoryOpenSheet"].firstMatch
            XCTAssertTrue(open.isHittable)
            open.tap()
            XCTAssertTrue(app.buttons["inventoryCloseSheet"].firstMatch.waitForExistence(timeout: 5), "A native tap must present the sheet")
        }
        let stem = "component--" + id.replacingOccurrences(of: "/", with: "--") + "--" + state + "--" + appearance
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = stem
        screenshot.lifetime = .keepAlways
        add(screenshot)
        let metadata: [String: String] = ["component_id": id, "state": state, "appearance": appearance,
            "capture_kind": "native_app_screenshot", "visual_review": "pending", "interaction_coverage": state == "sheet-open" ? "one_native_sheet_open_tap" : "not_implied",
            "source_revision": ProcessInfo.processInfo.environment["LAYERED_KIT_SOURCE_REVISION"] ?? "unrecorded",
            "os_version": ProcessInfo.processInfo.operatingSystemVersionString]
        let evidence = XCTAttachment(data: try JSONSerialization.data(withJSONObject: metadata, options: [.sortedKeys]), uniformTypeIdentifier: "public.json")
        evidence.name = stem + "--binding"
        evidence.lifetime = .keepAlways
        add(evidence)
    }

    private func matrix(_ ids: [String]) throws {
        for id in ids { for appearance in ["light", "dark"] { try capture(id, appearance: appearance) } }
    }

    func testSemanticMediaComponents() throws {
        try matrix(["semantic/media-frame", "semantic/avatar", "semantic/media-row", "semantic/media-backdrop"])
    }
    func testSemanticContentComponents() throws {
        try matrix(["semantic/labeled-value-row", "semantic/status-message", "semantic/section-header", "semantic/content-surface", "semantic/list-row", "semantic/sidebar-row"])
    }
    func testSemanticActionAndFieldComponents() throws {
        try matrix(["semantic/primary-action", "semantic/secondary-action", "semantic/text-field-modifier"])
    }
    func testCompositeIdentityAndMediaComponents() throws {
        try matrix(["composite/identity-header", "composite/media-detail-header", "composite/media-composer-header", "composite/category-rail"])
    }
    func testCompositeInputAndSelectionComponents() throws {
        try matrix(["composite/field-group", "composite/choice-row", "composite/selection-summary", "composite/conversation-composer"])
    }
    func testCompositeMessageAndRecordComponents() throws {
        try matrix(["composite/message-bubble", "composite/record-summary", "composite/utility-overlay"])
    }
    func testCompositeNativeRecipes() throws {
        try matrix(["composite/sectioned-media-collection", "composite/form-section", "composite/confirmation-content", "composite/status-content"])
    }
    func testListAndScrollShellComponents() throws {
        try matrix(["shell/flat-list", "shell/flat-scroll", "shell/grouped-form", "shell/ambient-scroll"])
    }
    func testTaskAndConversationShellComponents() throws {
        try matrix(["shell/focused-task", "shell/conversation", "shell/utility-canvas"])
    }
    func testNavigationAndHostShellComponents() throws {
        try matrix(["shell/adaptive-navigation", "shell/native-host"])
    }
    func testResolvedFoundationSamples() throws {
        try matrix(["primitive/corner-geometry", "foundation/color-role", "foundation/typography-role", "foundation/surface-role"])
    }
    func testExplicitAlternateStates() throws {
        for appearance in ["light", "dark"] {
            try capture("composite/category-rail", state: "empty", appearance: appearance)
            try capture("semantic/status-message", state: "error", appearance: appearance)
            try capture("semantic/text-field-modifier", state: "increased-contrast", appearance: appearance)
            try capture("semantic/media-backdrop", state: "increased-contrast", appearance: appearance)
        }
    }
    func testAccessibleReflowSamples() throws {
        for id in ["semantic/labeled-value-row", "composite/choice-row", "composite/identity-header", "composite/conversation-composer"] {
            try capture(id, state: "accessibility", appearance: "light")
            try capture(id, state: "rtl", appearance: "dark")
        }
    }
    func testNativeSheetPresentation() throws {
        for appearance in ["light", "dark"] {
            try capture("native/presentation-and-share-recipe", state: "sheet-open", appearance: appearance)
        }
    }
    func testNativeRecipeSamples1() throws {
        try matrix(["native/button-and-toolbar-action-recipe", "native/content-unavailable-view-recipe", "native/elevated-background-recipe", "native/hierarchical-style-recipe"])
    }
    func testNativeRecipeSamples2() throws {
        try matrix(["native/list-sidebar-and-disclosure-recipe", "native/material-and-glass-surface-recipe", "native/menu-context-and-edit-actions-recipe", "native/navigation-tabs-and-toolbars-recipe"])
    }
    func testNativeRecipeSamples3() throws {
        try matrix(["native/picker-and-date-color-input-recipe", "native/presentation-and-share-recipe", "native/progress-slider-stepper-recipe", "native/text-search-and-keyboard-input-recipe"])
    }

}
