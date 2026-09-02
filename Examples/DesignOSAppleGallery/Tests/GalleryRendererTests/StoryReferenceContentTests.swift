import DesignOSAppleCatalog
import XCTest

@testable import DESIGN_OS_Apple

final class StoryReferenceContentTests: XCTestCase {
  func testEveryAdmittedStoryHasExactlyOneCompleteReferenceContentRecord() {
    let records = StoryReferenceContent.all

    XCTAssertEqual(records.map(\.storyID), DesignOSStoryID.currentExecutableCases)
    XCTAssertEqual(
      Set(records.map(\.storyID)).count,
      DesignOSStoryID.currentExecutableCases.count
    )
    for record in records {
      XCTAssertFalse(record.whatItIs.isEmpty, record.storyID.rawValue)
      XCTAssertFalse(record.useWhen.isEmpty, record.storyID.rawValue)
      XCTAssertFalse(record.avoidWhen.isEmpty, record.storyID.rawValue)
      XCTAssertFalse(record.placement.isEmpty, record.storyID.rawValue)
      XCTAssertFalse(record.contract.isEmpty, record.storyID.rawValue)
      XCTAssertFalse(record.code.isEmpty, record.storyID.rawValue)
      XCTAssertLessThanOrEqual(
        record.code.split(separator: "\n").count, 18, record.storyID.rawValue)
    }
  }

  func testNativeRecipesNameTheirDirectNativeAPI() {
    let nativeIDs = DesignOSReleaseCatalog.stories
      .filter { $0.kind == .nativeRecipe }
      .map(\.id)

    for id in nativeIDs {
      let record = StoryReferenceContent.content(for: id)
      XCTAssertTrue(record.contract.contains(where: { $0.title == "Native API" }), id.rawValue)
    }
  }

  func testProductExamplesAndPrimitivesStateTheirBoundaries() {
    for story in DesignOSReleaseCatalog.stories where story.kind == .productDemo {
      XCTAssertTrue(
        StoryReferenceContent.content(for: story.id).contract.contains {
          $0.detail.contains("not public runtime API")
        },
        story.id.rawValue
      )
    }
    for story in DesignOSReleaseCatalog.stories where story.kind == .primitive {
      XCTAssertTrue(
        StoryReferenceContent.content(for: story.id).contract.contains {
          $0.title == "Preferred component"
        },
        story.id.rawValue
      )
    }
  }

  func testScrollableAndFullSceneExamplesOpenAsDestinations() {
    let destinationStories: [DesignOSStoryID] = [
      .profileCustomization, .colorRoles, .typographyRoles, .surfaceRoles,
      .listSidebarAndDisclosure, .navigationTabsAndToolbars, .pickerAndDateColorInput,
      .textSearchAndKeyboardInput, .systemDeviceChromeHost, .omniactSettingsShell,
      .tocchienDictionarySearch, .tocchienNavigationTabs,
    ]

    for id in destinationStories {
      XCTAssertEqual(StoryReferenceContent.content(for: id).preview, .destination, id.rawValue)
    }
  }

  func testCopyableExamplesUsePublicAPIsAndCompleteInitializers() {
    for record in StoryReferenceContent.all {
      XCTAssertFalse(
        record.code.contains("PlatformSemanticColor"),
        "\(record.storyID.rawValue) exposes an internal implementation type"
      )
    }

    let profileCode = StoryReferenceContent.content(for: .profileCustomization).code
    for argument in [
      "typography:", "spacing:", "radius:", "semanticColors:", "surface:", "accessibility:",
    ] {
      XCTAssertTrue(profileCode.contains(argument), "Missing \(argument)")
    }

    let listRowCode = StoryReferenceContent.content(for: .listRow).code
    XCTAssertLessThan(
      listRowCode.range(of: "NavigationLink")!.lowerBound,
      listRowCode.range(of: "DesignOSListRow")!.lowerBound
    )
    XCTAssertTrue(listRowCode.contains("label:"))

    let sidebarCode = StoryReferenceContent.content(for: .sidebarRow).code
    XCTAssertTrue(sidebarCode.contains("accessory:"))
    XCTAssertFalse(sidebarCode.contains("trailing:"))

    for id in [
      DesignOSStoryID.accessorySlotLayout, .sectionContentLayout,
      .sidebarToolbarContent, .symbolContent,
    ] {
      let code = StoryReferenceContent.content(for: id).code
      for packageOnlyType in [
        "AccessorySlotLayout", "SectionContentLayout", "SidebarToolbarContent", "SymbolContent",
      ] {
        XCTAssertFalse(code.contains(packageOnlyType), "\(id.rawValue) exposes \(packageOnlyType)")
      }
    }
  }

  func testCombinedContractRowsHaveUniqueSwiftUIIdentities() {
    for descriptor in DesignOSReleaseCatalog.stories {
      let content = StoryReferenceContent.content(for: descriptor.id)
      let facts = content.contract + descriptor.galleryPlatformFacts
      XCTAssertEqual(
        facts.map(\.id).count,
        Set(facts.map(\.id)).count,
        descriptor.id.rawValue
      )
    }
  }

  func testStoryDetailSharedChromeUsesDesignFloorsAndAdaptiveRows() throws {
    let page = try gallerySource(named: "StoryReferencePage")
    let support = try gallerySource(named: "StoryReferencePageSupport")
    let combined = page + support

    for forbidden in [
      "spacing: 30",
      ".padding(.horizontal, 9)",
      ".padding(.vertical, 5)",
      "spacing: 6",
      ".padding(.vertical, 9)",
      "spacing: 3",
      ".font(.system(size:",
      "DesignOSTypographyRole.caption2",
    ] {
      XCTAssertFalse(combined.contains(forbidden), "Story Detail floor rejects \(forbidden)")
    }

    XCTAssertGreaterThanOrEqual(
      combined.components(separatedBy: "ViewThatFits(in: .horizontal)").count - 1,
      4
    )
    XCTAssertTrue(support.contains("minWidth: GalleryDesignFloor.minimumHitTarget"))
    XCTAssertTrue(support.contains("minHeight: GalleryDesignFloor.minimumHitTarget"))
    XCTAssertTrue(page.contains("if dynamicTypeSize.isAccessibilitySize"))
    XCTAssertTrue(page.contains(".frame(maxWidth: .infinity, minHeight: height)"))
    XCTAssertTrue(page.contains("GalleryDesignFloor.minimumHitTarget"))
    XCTAssertFalse(combined.contains(".environment(\\.colorScheme"))
    XCTAssertFalse(combined.contains(".background(.white"))
  }

  private func gallerySource(named name: String) throws -> String {
    let file =
      galleryRoot
      .appendingPathComponent("App/Shared/Dogfood/Gallery")
      .appendingPathComponent("\(name).swift")
    return try String(contentsOf: file, encoding: .utf8)
  }

  private var galleryRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  }
}
