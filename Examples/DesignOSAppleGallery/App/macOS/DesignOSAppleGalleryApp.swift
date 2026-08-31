import SwiftUI

@main
struct DesignOSAppleGalleryApp: App {
  var body: some Scene {
    WindowGroup {
      DogfoodStoryHost { initialStorySelection in
        GalleryRootView(
          initialSelection: .catalog,
          initialStorySelection: initialStorySelection
        )
      }
      .frame(minWidth: 820, minHeight: 620)
    }
  }
}
