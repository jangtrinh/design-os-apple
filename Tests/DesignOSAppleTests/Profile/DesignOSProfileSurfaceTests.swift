import DesignOSApple
import SwiftUI
import Testing

@Test("Profiles admit only a finite nonnegative custom radius")
func profileValidatesCustomContentCornerRadius() throws {
  let profile = try DesignOSProfile(
    fontDesign: .standard,
    titleSubtitleSpacing: 2,
    sidebarContentSpacing: 8,
    listRowContentSpacing: 12,
    customContentCornerRadius: 18,
    surfaceRole: .translucentContent
  )
  #expect(profile.customContentCornerRadius == 18)
  #expect(profile.surfaceRole == .translucentContent)

  for invalid in [CGFloat.nan, -.leastNonzeroMagnitude, .infinity] {
    #expect(throws: DesignOSProfileError.invalid) {
      try DesignOSProfile(
        fontDesign: .standard,
        titleSubtitleSpacing: 2,
        sidebarContentSpacing: 8,
        listRowContentSpacing: 12,
        customContentCornerRadius: invalid,
        surfaceRole: .content
      )
    }
  }
}

@Test("Profile storage is limited to typed design-language groups")
func profileContainsNoProductControlState() {
  let labels = Set(Mirror(reflecting: DesignOSProfile.default).children.compactMap(\.label))
  #expect(
    labels == [
      "typography", "spacing", "radius", "semanticColors", "surface", "accessibility",
    ])
}
