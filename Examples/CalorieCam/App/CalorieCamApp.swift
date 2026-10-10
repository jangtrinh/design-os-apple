import SwiftUI
import DesignOSApple

@main
struct CalorieCamApp: App {
    @State private var model = JournalModel()
    @State private var aiSettings = AISettingsStore()

    var body: some Scene {
        WindowGroup {
            JournalView(model: model)
                .environment(aiSettings)
                .preferredColorScheme(aiSettings.appearance.colorScheme)
                .designOSAppStyle(.editorial)
                .tint(DesignOSAppStyle.editorial.palette.action.color)
        }
        #if os(macOS)
        .defaultSize(width: 960, height: 720)
        #endif
        #if os(macOS)
        Settings {
            AISettingsView(settings: aiSettings)
                .environment(aiSettings)
                .preferredColorScheme(aiSettings.appearance.colorScheme)
                .designOSAppStyle(.editorial)
                .tint(DesignOSAppStyle.editorial.palette.action.color)
        }
        #endif
    }
}
