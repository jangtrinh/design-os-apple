import DesignOSAppleCatalog
import SwiftUI

enum TocChienDogfoodPilotPlatform {
  case ios
  case macOS

  var markerPrefix: String {
    switch self {
    case .ios: "design-os.tocchien.ios.story"
    case .macOS: "design-os.tocchien.macos.story"
    }
  }
}

struct TocChienDogfoodPilotRootView: View {
  private let platform: TocChienDogfoodPilotPlatform
  private let selection: Result<DesignOSStorySelection?, DesignOSStorySelectorError>

  init(
    platform: TocChienDogfoodPilotPlatform,
    arguments: [String] = ProcessInfo.processInfo.arguments
  ) {
    self.platform = platform
    do {
      selection = .success(try DesignOSStorySelector.select(arguments: arguments))
    } catch let error as DesignOSStorySelectorError {
      selection = .failure(error)
    } catch {
      selection = .failure(.storyArgument)
    }
  }

  var body: some View {
    switch selection {
    case .success(.some(let selected)):
      selectedStory(selected)
    case .success(.none):
      failureMarker(.storyArgument)
    case .failure(let error):
      failureMarker(error)
    }
  }

  @ViewBuilder private func selectedStory(_ selected: DesignOSStorySelection) -> some View {
    switch selected.descriptor.id {
    case .tocchienDictionarySearch:
      supportedStory(selected) {
        TocChienDictionarySearchStory()
      }
    case .tocchienNavigationTabs:
      supportedStory(selected) {
        TocChienNavigationTabsStory()
      }
    case .tocchienChampionHeroNegativeControl:
      supportedStory(selected) {
        TocChienChampionHeroNegativeControlStory()
      }
    default:
      failureMarker(.unsupportedHost)
    }
  }

  private func supportedStory<Content: View>(
    _ selected: DesignOSStorySelection,
    @ViewBuilder content: () -> Content
  ) -> some View {
    NavigationStack {
      content()
      readyMarker(for: selected.descriptor.id)
    }
    .designOSProfile(selected.profile)
  }

  private func readyMarker(for storyID: DesignOSStoryID) -> some View {
    Text("Story ready")
      .accessibilityIdentifier("\(platform.markerPrefix).\(storyID.rawValue).ready")
  }

  private func failureMarker(_ error: DesignOSStorySelectorError) -> some View {
    VStack {
      ContentUnavailableView(
        "Story unavailable",
        systemImage: "exclamationmark.triangle",
        description: Text(error.rawValue)
      )
      Text(error.rawValue)
        .accessibilityIdentifier("\(platform.markerPrefix).selector-failure")
    }
  }
}
