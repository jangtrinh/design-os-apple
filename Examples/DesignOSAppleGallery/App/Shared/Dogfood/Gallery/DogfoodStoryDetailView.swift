import DesignOSAppleCatalog
import SwiftUI

struct DogfoodStoryDetailView: View {
  let descriptor: DesignOSStoryDescriptor

  var body: some View {
    DogfoodStoryCanvas(descriptor: descriptor)
      .id(descriptor.id)
      .navigationTitle(descriptor.title)
  }
}
