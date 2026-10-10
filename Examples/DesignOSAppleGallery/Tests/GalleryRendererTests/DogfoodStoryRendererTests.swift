import DesignOSAppleCatalog
import SwiftUI
import XCTest

@testable import DESIGN_OS_Apple

final class DogfoodStoryRendererTests: XCTestCase {
  @MainActor
  func testRendererInstantiatesEveryAdmittedDescriptor() {
    XCTAssertEqual(
      DesignOSReleaseCatalog.stories.count,
      DesignOSStoryID.currentExecutableCases.count
    )
    for descriptor in DesignOSReleaseCatalog.stories {
      let content = DogfoodStoryRenderer.render(descriptor: descriptor)
      acceptsView(content)
    }
  }

  private func acceptsView(_: some View) {}

  @MainActor
  func testMaterialAndGlassSelectionHonorsReduceTransparencyBeforeAvailability() {
    typealias Surface = NativeMaterialAndGlassSurfaceRecipeGallery.Surface

    // Exercise the actual specimen's policy, including older-OS fallbacks on
    // a new SDK. No duplicate test-only implementation selects the surface.
    XCTAssertEqual(Surface.resolve(reduceTransparency: true, supportsGlass: true), .opaque)
    XCTAssertEqual(Surface.resolve(reduceTransparency: true, supportsGlass: false), .opaque)
    XCTAssertEqual(Surface.resolve(reduceTransparency: false, supportsGlass: false), .material)
    XCTAssertEqual(Surface.resolve(reduceTransparency: false, supportsGlass: true), .glass)
  }

  @MainActor
  func testMaterialAndGlassAvailabilityMatchesHost() {
    #if compiler(>=6.2)
    if #available(macOS 26, *) {
      XCTAssertTrue(NativeMaterialAndGlassSurfaceRecipeGallery.supportsGlass)
    } else {
      XCTAssertFalse(NativeMaterialAndGlassSurfaceRecipeGallery.supportsGlass)
    }
    #else
    XCTAssertFalse(NativeMaterialAndGlassSurfaceRecipeGallery.supportsGlass)
    #endif

    acceptsView(NativeMaterialAndGlassSurfaceRecipeGallery())
    acceptsView(
      NativeMaterialAndGlassSurfaceRecipeGallery()
        .environment(\.accessibilityReduceTransparency, true)
    )
  }

  @MainActor
  func testMaterialAndGlassLabelsDescribeTheSelectedNativeSurface() {
    typealias Surface = NativeMaterialAndGlassSurfaceRecipeGallery.Surface
    XCTAssertEqual(Surface.opaque.label, "Opaque fallback · Reduce Transparency")
    XCTAssertEqual(Surface.material.label, "Native material · Glass unavailable")
    XCTAssertEqual(Surface.glass.label, "Native Liquid Glass")
  }
}
