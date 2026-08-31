import SwiftUI

@main
struct DesignOSAppleGalleryApp: App {
  var body: some Scene {
    WindowGroup {
      DogfoodStoryHost { initialStorySelection in
        GalleryRootView(initialStorySelection: initialStorySelection)
      }
    }
  }
}
