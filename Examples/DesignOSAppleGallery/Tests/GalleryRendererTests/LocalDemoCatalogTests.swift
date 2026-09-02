import DesignOSAppleCatalog
import Foundation
import XCTest

@testable import DESIGN_OS_Apple

final class LocalDemoCatalogTests: XCTestCase {
  func testLocalManifestExactlyMatchesTypedDefinitions() throws {
    let data = try Data(contentsOf: localManifestURL)
    let manifest = try JSONDecoder().decode(LocalDemoManifest.self, from: data)
    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let rows = try XCTUnwrap(object["demos"] as? [[String: Any]])

    XCTAssertEqual(Set(object.keys), ["schemaVersion", "distribution", "demos"])
    XCTAssertEqual(manifest.schemaVersion, 2)
    XCTAssertEqual(manifest.distribution, LocalDemoDistribution.localOnly.rawValue)
    XCTAssertEqual(manifest.demos, LocalDemoDefinition.all.map(LocalDemoManifest.Row.init))

    let expectedKeys: Set<String> = [
      "id", "section", "title", "flowLabel", "symbolName", "imageAssetName", "tint",
      "entryDestination", "detailDestination", "states", "patterns", "nativeAPIs",
      "sourcePaths", "assetNames", "platforms", "distribution",
    ]
    XCTAssertTrue(rows.allSatisfy { Set($0.keys) == expectedKeys })
    for row in manifest.demos {
      XCTAssertEqual(row.states.count, 2)
      for path in row.sourcePaths {
        XCTAssertTrue(
          FileManager.default.fileExists(atPath: galleryRoot.appendingPathComponent(path).path))
      }
    }
  }

  func testSixDemosOwnTwelveUniqueStatesInSectionOrder() {
    XCTAssertEqual(LocalDemoDefinition.all.count, 6)
    XCTAssertEqual(
      LocalDemoDefinition.all.map(\.section),
      [
        .assistants, .assistants, .mobility, .mobility, .entertainment, .entertainment,
      ])
    let stateIDs = LocalDemoDefinition.all.flatMap { $0.states.map(\.id) }
    XCTAssertEqual(stateIDs.count, 12)
    XCTAssertEqual(Set(stateIDs).count, 12)
    XCTAssertTrue(
      LocalDemoSection.allCases.allSatisfy {
        LocalDemoDefinition.demos(in: $0).count == 2
      })
  }

  func testLocalIDsAreUniqueAndDisjointFromReleaseAuthorities() throws {
    let localIDs = LocalDemoDefinition.all.map(\.id)
    XCTAssertEqual(Set(localIDs).count, localIDs.count)
    XCTAssertTrue(LocalDemoDefinition.all.allSatisfy { $0.distribution == .localOnly })

    let typedReleaseIDs = Set(DesignOSReleaseCatalog.stories.map { $0.id.rawValue })
    XCTAssertTrue(Set(localIDs).isDisjoint(with: typedReleaseIDs))

    let data = try Data(
      contentsOf: galleryRoot.appendingPathComponent(
        "Generated/design-os-apple-catalog-bundle.v2.json"))
    let bundle = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let releaseManifest = try XCTUnwrap(bundle["manifest"] as? [String: Any])
    let stories = try XCTUnwrap(releaseManifest["stories"] as? [[String: Any]])
    let bundleIDs = Set(try stories.map { try XCTUnwrap($0["id"] as? String) })
    XCTAssertEqual(bundleIDs, typedReleaseIDs)
    XCTAssertTrue(Set(localIDs).isDisjoint(with: bundleIDs))
  }

  private var galleryRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  }

  private var localManifestURL: URL {
    galleryRoot.appendingPathComponent("Generated/local-demo-catalog.v2.json")
  }
}

private struct LocalDemoManifest: Decodable {
  let schemaVersion: Int
  let distribution: String
  let demos: [Row]

  struct State: Codable, Equatable {
    let id: String
    let title: String
    let view: String
  }

  struct Row: Codable, Equatable {
    let id: String
    let section: String
    let title: String
    let flowLabel: String
    let symbolName: String
    let imageAssetName: String
    let tint: String
    let entryDestination: String
    let detailDestination: String
    let states: [State]
    let patterns: [String]
    let nativeAPIs: [String]
    let sourcePaths: [String]
    let assetNames: [String]
    let platforms: [String]
    let distribution: String

    init(_ definition: LocalDemoDefinition) {
      id = definition.id
      section = definition.section.rawValue
      title = definition.title
      flowLabel = definition.flowLabel
      symbolName = definition.symbolName
      imageAssetName = definition.imageAssetName
      tint = definition.tint.rawValue
      entryDestination = definition.entryDestination.rawValue
      detailDestination = definition.detailDestination.rawValue
      states = definition.states.map { .init(id: $0.id, title: $0.title, view: $0.view) }
      patterns = definition.patterns
      nativeAPIs = definition.nativeAPIs
      sourcePaths = definition.sourcePaths
      assetNames = definition.assetNames
      platforms = definition.platforms
      distribution = definition.distribution.rawValue
    }
  }
}
