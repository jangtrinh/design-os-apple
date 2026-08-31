import DesignOSApple
import DesignOSAppleCatalog
import SwiftUI

struct DogfoodStoryDetailView: View {
  let selection: DesignOSStorySelection

  var body: some View {
    DogfoodStoryCanvas(descriptor: selection.descriptor)
      .id(selection.descriptor.id)
      .designOSProfile(selection.profile)
      .navigationTitle(selection.descriptor.title)
  }
}
