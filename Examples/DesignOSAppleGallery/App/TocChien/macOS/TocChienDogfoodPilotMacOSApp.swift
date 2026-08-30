import SwiftUI

@main
struct TocChienDogfoodPilotMacOSApp: App {
  var body: some Scene {
    WindowGroup {
      TocChienDogfoodPilotRootView(platform: .macOS)
        .frame(minWidth: 720, minHeight: 520)
    }
  }
}
