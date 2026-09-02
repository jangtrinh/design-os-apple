import DesignOSAppleCatalog
import SwiftUI

struct GalleryRootView: View {
  @State private var selection: GalleryDestination?
  @State private var storyPath: NavigationPath
  @Namespace private var localDemoTransitionNamespace

  init(
    initialSelection: GalleryDestination? = .catalog,
    initialStorySelection: DesignOSStorySelection? = nil
  ) {
    var path = NavigationPath()
    if let initialStorySelection {
      path.append(initialStorySelection)
    }
    _selection = State(initialValue: initialSelection)
    _storyPath = State(initialValue: path)
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
          .navigationDestination(for: StoryPreviewDestination.self) { destination in
            DogfoodStoryCanvas(descriptor: destination.selection.descriptor)
              .designOSProfile(destination.selection.profile)
              .navigationTitle(destination.selection.descriptor.title)
          }
          .navigationDestination(for: LocalDemoDestination.self) { destination in
            localDemo(destination)
          }
      }
      .environment(\.localDemoTransitionNamespace, localDemoTransitionNamespace)
    }
    .onChange(of: selection) { oldValue, newValue in
      if oldValue != newValue {
        storyPath = NavigationPath()
      }
    }
  }

  @ViewBuilder
  private var detail: some View {
    switch selection {
    case .catalog:
      DogfoodCatalogView()
    case .examples:
      LocalDemoGalleryView()
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

  @ViewBuilder
  private func localDemo(_ destination: LocalDemoDestination) -> some View {
    Group {
      switch destination {
      case .thoughtfulChatHome:
        ThoughtfulChatHomeDemoView()
      case .thoughtfulChatThread:
        ThoughtfulChatThreadDemoView()
      case .visualAssistantHome:
        VisualAssistantHomeDemoView()
      case .visualAssistantAnswer:
        VisualAssistantAnswerDemoView()
      case .flightTrackerBoard:
        FlightTrackerBoardDemoView()
      case .flightTrackerLive:
        FlightTrackerLiveDemoView()
      case .cityRideSelection:
        CityRideSelectionDemoView()
      case .cityRideTracking:
        CityRideTrackingDemoView()
      case .streamingLibraryBrowse:
        StreamingLibraryBrowseDemoView()
      case .songFinderListening:
        SongFinderListeningDemoView()
      case .songFinderResult:
        SongFinderResultDemoView()
      }
    }
    .localDemoDestinationTransition(destination)
  }
}
