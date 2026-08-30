import DesignOSApple
import DesignOSAppleCatalog
import SwiftUI

struct DogfoodStoryCanvas: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let descriptor: DesignOSStoryDescriptor

  var body: some View {
    ZStack {
      let content = DogfoodStoryRenderer.render(descriptor: descriptor)
      switch DogfoodStoryPresentation.presentation(for: descriptor.id) {
      case .fullBleed:
        content
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      case .contained:
        contained(content)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("design-os.gallery.story.\(descriptor.id.rawValue).ready")
  }

  private func contained<Content: View>(_ content: Content) -> some View {
    ZStack {
      DesignOSColorRole.backgroundPrimary.color
      content
        .frame(maxWidth: containedMaxWidth, maxHeight: .infinity)
        .padding()
    }
  }

  private var containedMaxWidth: CGFloat {
    horizontalSizeClass == .compact ? .infinity : 720
  }
}
