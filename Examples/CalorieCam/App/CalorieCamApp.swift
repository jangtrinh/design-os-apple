import SwiftUI
import DesignOSApple

@main
struct CalorieCamApp: App {
    @State private var model = JournalModel()

    var body: some Scene {
        WindowGroup {
            JournalView(model: model)
                .designOSProfile(.default)
        }
        #if os(macOS)
        .defaultSize(width: 960, height: 720)
        #endif
    }
}
