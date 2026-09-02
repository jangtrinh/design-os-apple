import CoreGraphics
import DesignOSAppleCatalog

struct StoryReferenceContent: Equatable {
  let storyID: DesignOSStoryID
  let whatItIs: String
  let useWhen: String
  let avoidWhen: String
  let placement: String
  let contract: [StoryReferenceFact]
  let code: String
  let preview: StoryPreviewPresentation

  static let all: [Self] =
    foundationReferenceContent
    + componentReferenceContent
    + nativeReferenceContentA
    + nativeReferenceContentB
    + extensionAndProductReferenceContent

  static func content(for storyID: DesignOSStoryID) -> Self {
    guard let content = all.first(where: { $0.storyID == storyID }) else {
      preconditionFailure("Every admitted story requires instructional reference content.")
    }
    return content
  }
}

struct StoryReferenceFact: Equatable, Identifiable {
  let title: String
  let detail: String

  var id: String { title }
}

enum StoryPreviewPresentation: Equatable {
  case intrinsic
  case bounded(StoryPreviewHeight)
  case destination
}

enum StoryPreviewHeight: CGFloat, Equatable {
  case compact = 220
  case standard = 320
}
