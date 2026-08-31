import DesignOSAppleCatalog
import SwiftUI

struct DogfoodStoryHost<Catalog: View>: View {
  private let selection: Result<DesignOSStorySelection?, DesignOSStorySelectorError>
  private let catalog: (DesignOSStorySelection?) -> Catalog

  init(
    arguments: [String] = ProcessInfo.processInfo.arguments,
    @ViewBuilder catalog: @escaping (DesignOSStorySelection?) -> Catalog
  ) {
    do {
      selection = .success(try DesignOSStorySelector.select(arguments: arguments))
    } catch let error as DesignOSStorySelectorError {
      selection = .failure(error)
    } catch {
      selection = .failure(.storyArgument)
    }
    self.catalog = catalog
  }

  var body: some View {
    switch selection {
    case .success(let selected):
      catalog(selected)
    case .failure(let error):
      VStack {
        ContentUnavailableView(
          "Story selector failed",
          systemImage: "exclamationmark.triangle",
          description: Text(error.rawValue)
        )
        Text(error.rawValue)
          .accessibilityIdentifier("design-os.gallery.story.selector-failure")
      }
    }
  }
}
