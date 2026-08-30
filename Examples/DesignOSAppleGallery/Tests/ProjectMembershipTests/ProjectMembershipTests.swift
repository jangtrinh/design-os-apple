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
      "OmniActHUDSurfaceResolver.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "OmniActHUDStoryFixtures.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "OmniActHUDAutocompleteMaterialStory.swift": [
        "DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS",
      ],
      "DogfoodStoryRendererTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "DogfoodCatalogViewTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "DogfoodStoryPresentationTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "OmniActHUDSurfaceResolverTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "TocChienDictionarySearchStoryTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "ProjectMembershipTests.swift": ["DesignOSAppleGalleryRendererTests"],
      "DesignOSAppleGalleryUITests.swift": ["DesignOSAppleGalleryUITests"],
      "DesignOSAppleGalleryStoryUITests.swift": ["DesignOSAppleGalleryUITests"],
      "DesignOSAppleGalleryMacOSUITests.swift": ["DesignOSAppleGalleryMacOSUITests"],
      "TocChienDogfoodPilotIOSUITests.swift": ["TocChienDogfoodPilotIOSUITests"],
      "TocChienDogfoodPilotMacOSUITests.swift": ["TocChienDogfoodPilotMacOSUITests"],
    ]
    for (source, targetSet) in expected {
      let actual = try targetMembership(of: source, among: targets, project: contents)
      XCTAssertEqual(actual, targetSet, "Unexpected target membership for \(source)")
    }
    XCTAssertFalse(contents.contains("TocChienNavigationTabsStory.swift in Resources"))
    XCTAssertFalse(contents.contains("TocChienChampionHeroNegativeControlStory.swift in Resources"))
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
