import DesignOSApple
import DesignOSAppleCatalog
import SwiftUI

struct DogfoodStoryDetailView: View {
  let selection: DesignOSStorySelection

  var body: some View {
    StoryReferencePage(
      selection: selection,
      content: StoryReferenceContent.content(for: selection.descriptor.id),
      primaryKeyword: selection.descriptor.discovery.primaryKeyword,
      kindLabel: selection.descriptor.galleryKindLabel,
      ownershipLabel: selection.descriptor.galleryOwnershipLabel,
      platformFacts: selection.descriptor.galleryPlatformFacts,
      relatedStories: selection.descriptor.galleryRelatedStories
    )
    .id(selection.descriptor.id)
    .designOSProfile(selection.profile)
    .navigationTitle(selection.descriptor.title)
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
  }
}
