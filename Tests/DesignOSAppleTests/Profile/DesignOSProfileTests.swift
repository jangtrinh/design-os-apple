import DesignOSApple
import SwiftUI
import Testing

@Test("Default profile preserves Phase 1 typography and spacing")
func defaultProfilePreservesPhaseOneValues() {
  #expect(DesignOSProfile.default.fontDesign == .standard)
  #expect(DesignOSProfile.default.titleSubtitleSpacing == 2)
  #expect(DesignOSProfile.default.sidebarContentSpacing == 8)
  #expect(DesignOSProfile.default.listRowContentSpacing == 12)
}

@Test("Custom profiles change only their supplied typography and spacing")
func customProfileChangesSuppliedValues() throws {
  let custom = try commandRowProfile()
  #expect(custom.fontDesign == .expressive)
  #expect(custom.listRowContentSpacing == 10)
  #expect(
    custom.titleSubtitleSpacing == DesignOSProfile.default.titleSubtitleSpacing)
  #expect(
    custom.sidebarContentSpacing == DesignOSProfile.default.sidebarContentSpacing)
}

private func commandRowProfile() throws -> DesignOSProfile {
  try DesignOSProfile(
    fontDesign: .expressive,
    titleSubtitleSpacing: 2,
    sidebarContentSpacing: 8,
    listRowContentSpacing: 10
  )
}

@Test("Profile validates each spacing axis independently")
func profileRejectsInvalidSpacingIndependently() throws {
  for invalid in [CGFloat.nan, -.leastNonzeroMagnitude, .infinity] {
    #expect(throws: DesignOSProfileError.invalid) {
      try DesignOSProfile(
        fontDesign: .standard,
        titleSubtitleSpacing: invalid,
        sidebarContentSpacing: 1,
        listRowContentSpacing: 0
      )
    }
    #expect(throws: DesignOSProfileError.invalid) {
      try DesignOSProfile(
        fontDesign: .standard,
        titleSubtitleSpacing: 9,
        sidebarContentSpacing: invalid,
        listRowContentSpacing: 0
      )
    }
    #expect(throws: DesignOSProfileError.invalid) {
      try DesignOSProfile(
        fontDesign: .standard,
        titleSubtitleSpacing: 9,
        sidebarContentSpacing: 1,
        listRowContentSpacing: invalid
      )
    }
  }
  #expect(
    try DesignOSProfile(
      fontDesign: .standard,
      titleSubtitleSpacing: 9,
      sidebarContentSpacing: 1,
      listRowContentSpacing: 0
    ).titleSubtitleSpacing == 9)
}

@Test("Profile rejects unsupported semantic font design identifiers")
func profileRejectsUnsupportedFontDesign() {
  #expect(throws: DesignOSProfileError.invalid) {
    try DesignOSProfile(
      fontDesignID: "unsupported",
      titleSubtitleSpacing: 2,
      sidebarContentSpacing: 8,
      listRowContentSpacing: 12
    )
  }
}
