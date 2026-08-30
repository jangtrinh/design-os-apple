import SwiftUI

@main
struct DesignOSAppleGalleryApp: App {
  var body: some Scene {
    WindowGroup {
      DogfoodStoryHost {
        GalleryRootView(initialSelection: .catalog)
      }
      .frame(minWidth: 820, minHeight: 620)
    }
  }
}
