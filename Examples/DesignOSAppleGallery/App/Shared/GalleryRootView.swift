import DesignOSAppleCatalog
import SwiftUI

struct GalleryRootView: View {
  @State private var selection: GalleryDestination?
  @State private var storyPath: [DesignOSStorySelection]

  init(
    initialSelection: GalleryDestination? = .catalog,
    initialStorySelection: DesignOSStorySelection? = nil
  ) {
    _selection = State(initialValue: initialSelection)
    _storyPath = State(initialValue: initialStorySelection.map { [$0] } ?? [])
  }

  var body: some View {
    NavigationSplitView {
      List(GalleryDestination.allCases, selection: $selection) { destination in
        NavigationLink(value: destination) {
          Label(destination.rawValue, systemImage: destination.symbolName)
        }
      }
      .navigationTitle("Apple Design OS")
    } detail: {
      NavigationStack(path: $storyPath) {
        detail
          .navigationTitle(selection?.rawValue ?? "Apple Design OS")
          .navigationDestination(for: DesignOSStorySelection.self) { storySelection in
            DogfoodStoryDetailView(selection: storySelection)
          }
      }
    }
  }

  @ViewBuilder
  private var detail: some View {
    switch selection {
    case .catalog:
      DogfoodCatalogView()
    case .overview:
      GalleryOverview()
    case .foundations:
      FoundationGallery()
    case .semanticComponents:
      SemanticComponentsGallery()
    case .nativePatterns:
      NativePatternsGallery()
    case nil:
      ContentUnavailableView(
        "Choose a gallery",
        systemImage: "sidebar.left",
        description: Text("Select a design-system surface from the sidebar.")
      )
    }
  }
}
