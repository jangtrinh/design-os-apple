import DesignOSAppleCatalog
import Foundation
import Testing

@Test("Runtime catalog owns the exact release-candidate deliverable set")
func runtimeCatalogOwnsExactDeliverables() throws {
  let deliverables = DesignOSRuntimeCatalog.deliverables
  #expect(deliverables.count == 27)
  #expect(deliverables.map(\.id) == RuntimeDeliverableID.allCases)
  #expect(Set(deliverables.map(\.id)).count == deliverables.count)

  for deliverable in deliverables {
    #expect(!deliverable.module.isEmpty)
    #expect(!deliverable.symbolOrNativeAPI.isEmpty)
    #expect(!deliverable.platforms.isEmpty)
    #expect(Set(deliverable.platforms).count == deliverable.platforms.count)
    #expect(Set(deliverable.minimumAvailability.map(\.platform)) == Set(deliverable.platforms))
    #expect(!deliverable.fallback.isEmpty)
    #expect(!deliverable.documentationPath.isEmpty)
    #expect(!deliverable.examplePath.isEmpty)
    #expect(!deliverable.verificationCommand.isEmpty)
    #expect(try DesignOSRuntimeCatalog.deliverable(for: deliverable.id) == deliverable)
    deliverable.id.resolvesCompiledRuntimeSymbol()
  }
}

@Test("Every runtime deliverable has one executable canonical story and valid foreign keys")
func everyDeliverableHasCanonicalStory() throws {
  let stories = DesignOSReleaseCatalog.stories
  let storiesByID = Dictionary(uniqueKeysWithValues: stories.map { ($0.id, $0) })

  for deliverable in DesignOSRuntimeCatalog.deliverables {
    let storyID = try #require(deliverable.storyDisposition.storyID)
    let story = try #require(storiesByID[storyID])
    #expect(story.runtimeDeliverableID == deliverable.id)
    #expect(story.examplePath == deliverable.examplePath)
  }

  let deliverableIDs = Set(DesignOSRuntimeCatalog.deliverables.map(\.id))
  for story in stories {
    if let runtimeDeliverableID = story.runtimeDeliverableID {
      #expect(deliverableIDs.contains(runtimeDeliverableID))
    }
  }
}

@Test("Metadata stays identity-only and excludes product state")
func metadataExcludesProductState() {
  let forbidden = ["panelWidth", "rowCapacity", "commandState", "providerName", "productState"]
  for deliverable in DesignOSRuntimeCatalog.deliverables {
    let text = [
      deliverable.module,
      deliverable.symbolOrNativeAPI,
      deliverable.fallback,
      deliverable.documentationPath,
      deliverable.examplePath,
      deliverable.verificationCommand,
    ].joined(separator: " ")
    for field in forbidden {
      #expect(!text.contains(field))
    }
  }
}

@Test("Every leaf Gallery surface has exactly one typed executable route")
func everyLeafGallerySurfaceHasOneRoute() throws {
  let routedPaths = DesignOSReleaseCatalog.stories.map(\.examplePath)
  let compiledPaths = try compiledLeafGalleryPaths()
  #expect(Set(routedPaths).count == routedPaths.count)
  #expect(Set(routedPaths) == compiledPaths)
  for path in routedPaths {
    #expect(
      FileManager.default.fileExists(atPath: repositoryRoot.appendingPathComponent(path).path))
  }
}

private var repositoryRoot: URL {
  URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
}

private func compiledLeafGalleryPaths() throws -> Set<String> {
  let gallery = repositoryRoot.appendingPathComponent("Examples/DesignOSAppleGallery")
  let directories = [
    gallery,
    gallery.appendingPathComponent("Components"),
    gallery.appendingPathComponent("Extensions"),
    gallery.appendingPathComponent("Primitives"),
    gallery.appendingPathComponent("App/Shared/Dogfood/Shared"),
  ]
  return try Set(
    directories.flatMap { directory in
      try FileManager.default.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
      ).filter { url in
        let name = url.lastPathComponent
        return name.hasSuffix("Gallery.swift") || name.hasSuffix("Story.swift")
      }.map { url in
        url.path.replacingOccurrences(of: repositoryRoot.path + "/", with: "")
      }
    })
}
