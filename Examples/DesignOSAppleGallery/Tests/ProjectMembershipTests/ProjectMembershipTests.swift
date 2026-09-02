import Foundation
import XCTest

final class ProjectMembershipTests: XCTestCase {
  func testPilotSourcesHaveExactTargetMembership() throws {
    let contents = try String(contentsOf: projectURL, encoding: .utf8)
    let targets = [
      "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      "DesignOSAppleGalleryRendererTests", "DesignOSAppleGalleryMacOSUITests",
      "DesignOSAppleGalleryUITests",
      "TocChienDogfoodPilot-iOS", "TocChienDogfoodPilot-macOS",
      "TocChienDogfoodPilotIOSUITests", "TocChienDogfoodPilotMacOSUITests",
    ]
    let expected: [String: Set<String>] = [
      "ProfileCustomizationGallery.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "LocalDemoDestination.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "LocalDemoDefinition.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "LocalDemoGalleryView.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "LocalDemoAdaptiveColor.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "LocalDemoDefinitions+Assistants.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "LocalDemoDefinitions+Mobility.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "LocalDemoDefinitions+Entertainment.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "ThoughtfulChatHomeDemoView.swift": galleryTargets,
      "ThoughtfulChatThreadDemoView.swift": galleryTargets,
      "VisualAssistantHomeDemoView.swift": galleryTargets,
      "VisualAssistantAnswerDemoView.swift": galleryTargets,
      "FlightTrackerBoardDemoView.swift": galleryTargets,
      "FlightTrackerLiveDemoView.swift": galleryTargets,
      "CityRideSelectionDemoView.swift": galleryTargets,
      "CityRideTrackingDemoView.swift": galleryTargets,
      "StreamingLibraryBrowseDemoView.swift": galleryTargets,
      "StreamingLibraryHero.swift": galleryTargets,
      "SongFinderListeningDemoView.swift": galleryTargets,
      "SongFinderResultDemoView.swift": galleryTargets,
      "CatalogStorySection.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "CatalogStoryThumbnail.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "DogfoodCatalogCard.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "DogfoodCatalogView.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "DogfoodStoryCanvas.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "DogfoodStoryDetailView.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "DogfoodStoryHost.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "DogfoodStoryPresentation.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "DogfoodStoryRenderer.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "DesignOSStoryDescriptor+GalleryPresentation.swift": galleryTargets,
      "StoryPreviewDestination.swift": galleryTargets,
      "StoryReferenceContent.swift": galleryTargets,
      "StoryReferenceContent+Components.swift": galleryTargets,
      "StoryReferenceContent+ExtensionsAndProducts.swift": galleryTargets,
      "StoryReferenceContent+Foundations.swift": galleryTargets,
      "StoryReferenceContent+NativeRecipesA.swift": galleryTargets,
      "StoryReferenceContent+NativeRecipesB.swift": galleryTargets,
      "StoryReferencePage.swift": galleryTargets,
      "StoryReferencePageSupport.swift": galleryTargets,
      "TocChienDictionaryFixtures.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS", "TocChienDogfoodPilot-iOS",
        "TocChienDogfoodPilot-macOS",
      ],
      "TocChienDictionarySearchStory.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS", "TocChienDogfoodPilot-iOS",
        "TocChienDogfoodPilot-macOS",
      ],
      "TocChienNavigationTabsStory.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS", "TocChienDogfoodPilot-iOS",
        "TocChienDogfoodPilot-macOS",
      ],
      "TocChienChampionHeroNegativeControlStory.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS", "TocChienDogfoodPilot-iOS",
        "TocChienDogfoodPilot-macOS",
      ],
      "TocChienDogfoodPilotRootView.swift": [
        "TocChienDogfoodPilot-iOS", "TocChienDogfoodPilot-macOS",
      ],
      "TocChienDogfoodPilotIOSApp.swift": ["TocChienDogfoodPilot-iOS"],
      "TocChienDogfoodPilotMacOSApp.swift": ["TocChienDogfoodPilot-macOS"],
      "OmniActCommandRowStory.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "OmniActSettingsStory.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "OmniActSettingsValues.swift": ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"],
      "DogfoodStoryRendererTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "DogfoodCatalogViewTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "DogfoodStoryPresentationTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "StoryReferenceContentTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "LocalDemoCatalogTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "AssistantMiniAppTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "MobilityMiniAppTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "EntertainmentMiniAppTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "TocChienDictionarySearchStoryTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "ProjectMembershipTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "DesignOSAppleGalleryUITests.swift": ["DesignOSAppleGalleryUITests"],
      "DesignOSAppleGalleryStoryUITests.swift": ["DesignOSAppleGalleryUITests"],
      "DesignOSAppleGalleryDesignFloorUITests.swift": ["DesignOSAppleGalleryUITests"],
      "DesignOSAppleGalleryLocalDemoUITests.swift": ["DesignOSAppleGalleryUITests"],
      "DesignOSAppleGalleryMacOSUITests.swift": ["DesignOSAppleGalleryMacOSUITests"],
      "DesignOSAppleGalleryLocalDemoMacOSUITests.swift": [
        "DesignOSAppleGalleryMacOSUITests"
      ],
      "TocChienDogfoodPilotIOSUITests.swift": ["TocChienDogfoodPilotIOSUITests"],
      "TocChienDogfoodPilotMacOSUITests.swift": ["TocChienDogfoodPilotMacOSUITests"],
    ]
    for (source, targetSet) in expected {
      let actual = try targetMembership(of: source, among: targets, project: contents)
      XCTAssertEqual(actual, targetSet, "Unexpected target membership for \(source)")
    }
    XCTAssertFalse(contents.contains("TocChienNavigationTabsStory.swift in Resources"))
    XCTAssertFalse(contents.contains("TocChienChampionHeroNegativeControlStory.swift in Resources"))
    XCTAssertTrue(contents.contains("CatalogThumbnails.xcassets in Resources"))
    XCTAssertTrue(contents.contains("LocalDemoMedia.xcassets in Resources"))
  }

  private var galleryTargets: Set<String> {
    ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"]
  }

  private var projectURL: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
      .appendingPathComponent("DesignOSAppleGallery.xcodeproj/project.pbxproj")
  }

  private func targetMembership(of source: String, among targets: [String], project: String) throws
    -> Set<String>
  {
    guard let buildFiles = section("PBXBuildFile", in: project),
      let sources = section("PBXSourcesBuildPhase", in: project),
      let nativeTargets = section("PBXNativeTarget", in: project)
    else { throw MembershipError.malformedProject }
    let buildFileIDs = Set(
      captures(
        "([A-F0-9]{24}) /\\* \(NSRegularExpression.escapedPattern(for: source)) in Sources \\*/",
        from: buildFiles
      ))
    let sourcePhaseIDs = sourcePhases(containing: buildFileIDs, source: source, in: sources)
    guard !buildFileIDs.isEmpty, !sourcePhaseIDs.isEmpty else {
      throw MembershipError.malformedProject
    }
    return Set(
      targets.filter { target in
        nativeTargets.components(separatedBy: "\n\t\t};").contains { record in
          let hasName =
            record.contains("name = \(target);") || record.contains("name = \"\(target)\";")
          return hasName && sourcePhaseIDs.contains { record.contains("\($0) /* Sources */") }
        }
      })
  }

  private func section(_ name: String, in project: String) -> String? {
    let startMarker = "/* Begin \(name) section */"
    let endMarker = "/* End \(name) section */"
    guard let start = project.range(of: startMarker)?.upperBound,
      let end = project.range(of: endMarker, range: start..<project.endIndex)?.lowerBound
    else { return nil }
    return String(project[start..<end])
  }

  private func sourcePhases(containing buildFileIDs: Set<String>, source: String, in text: String)
    -> Set<String>
  {
    let regex = try! NSRegularExpression(
      pattern: "([A-F0-9]{24}) /\\* Sources \\*/ = \\{.*?files = \\((.*?)\\);",
      options: [.dotMatchesLineSeparators]
    )
    let range = NSRange(text.startIndex..., in: text)
    return Set(
      regex.matches(in: text, range: range).compactMap { match in
        guard let files = Range(match.range(at: 2), in: text),
          buildFileIDs.contains(where: { text[files].contains("\($0) /* \(source) in Sources */") })
        else { return nil }
        return Range(match.range(at: 1), in: text).map { String(text[$0]) }
      })
  }

  private func captures(_ pattern: String, from text: String) -> [String] {
    let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
    let range = NSRange(text.startIndex..., in: text)
    return regex.matches(in: text, range: range).compactMap { match in
      let capture = match.numberOfRanges > 1 ? match.range(at: 1) : match.range
      guard let range = Range(capture, in: text) else { return nil }
      return String(text[range])
    }
  }

  private enum MembershipError: Error { case malformedProject }
}
