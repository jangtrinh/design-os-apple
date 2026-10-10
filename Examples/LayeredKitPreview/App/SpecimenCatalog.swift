import SwiftUI

enum Specimen: String, CaseIterable, Identifiable {
    case foundations, composites, shells
    case flatCollection = "flat-collection"
    case mediaDetail = "media-detail"
    case mediaComposer = "media-composer"
    case groupedForm = "grouped-form"
    case focusedTask = "focused-task"
    case onboarding, discovery
    case profileDetail = "profile-detail"
    case heroCollection = "hero-collection"
    case freeformEditor = "freeform-editor"
    case searchSelection = "search-selection"
    case confirmation, status
    case messageThread = "message-thread"
    case utilityCanvas = "utility-canvas"
    case providerHost = "provider-host"
    case recordDetail = "record-detail"
    case nativePresentation = "native-presentation"

    var id: String { rawValue }
    var title: String { rawValue.replacingOccurrences(of: "-", with: " ").capitalized }
    var available: Bool { true }
    static var screens: [Self] { allCases.filter { ![.foundations, .composites, .shells].contains($0) } }
}

enum PreviewAppearance: String, CaseIterable {
    case system, light, dark
    var scheme: ColorScheme? {
        switch self { case .system: nil; case .light: .light; case .dark: .dark }
    }
}

enum PreviewState: String, CaseIterable {
    case populated, empty, error, busy
}
