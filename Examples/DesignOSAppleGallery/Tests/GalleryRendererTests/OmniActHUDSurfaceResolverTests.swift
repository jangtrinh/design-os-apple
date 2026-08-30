import DesignOSApple
import XCTest

@testable import DESIGN_OS_Apple

final class OmniActHUDSurfaceResolverTests: XCTestCase {
  func testReducedTransparencyUsesOpaqueSemanticBackground() throws {
    XCTAssertEqual(
      OmniActHUDSurfaceResolver.path(profile: try hudProfile(), reduceTransparency: true),
      .opaqueBackground
    )
  }

  func testStandardTransparencyUsesNativeMaterial() throws {
    XCTAssertEqual(
      OmniActHUDSurfaceResolver.path(profile: try hudProfile(), reduceTransparency: false),
      .nativeMaterial
    )
  }

  private func hudProfile() throws -> DesignOSProfile {
    try DesignOSProfile(
      fontDesign: .standard,
      titleSubtitleSpacing: 2,
      sidebarContentSpacing: 8,
      listRowContentSpacing: 12,
      customContentCornerRadius: 18,
      surfaceRole: .translucentContent
    )
  }
}
