import DesignOSAppleCatalog
import SwiftUI

struct GalleryRootView: View {
  @State private var selection: GalleryDestination?

  init(initialSelection: GalleryDestination? = .catalog) {
    _selection = State(initialValue: initialSelection)
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
      NavigationStack {
        detail
          .navigationTitle(selection?.rawValue ?? "Apple Design OS")
          .navigationDestination(for: DesignOSStoryDescriptor.self) { descriptor in
            DogfoodStoryDetailView(descriptor: descriptor)
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
