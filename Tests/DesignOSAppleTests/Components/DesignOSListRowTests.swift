import DesignOSApple
import SwiftUI
import Testing

@testable import DesignOSApple

@Test("List row composes caller-owned content without owning interaction")
@MainActor
func designOSListRowCompiles() {
  let row = DesignOSListRow {
    Image(systemName: "doc")
  } title: {
    Text("Document")
  } subtitle: {
    Text("Updated today")
  } trailing: {
    Text("12 KB")
  }

  #expect(String(reflecting: type(of: row)).contains("DesignOSListRow"))
}

@Test("List row supports title-only content")
@MainActor
func designOSListRowTitleOnlyCompiles() {
  let row = DesignOSListRow {
    Text("Simple row")
  }

  #expect(String(reflecting: type(of: row)).contains("DesignOSListRow"))
}

@Test("List row profile metrics preserve defaults and consume custom list-row spacing")
func designOSListRowProfileMetrics() throws {
  let custom = try commandRowProfile()
  #expect(DesignOSListRowMetrics.contentSpacing(for: .default) == 12)
  #expect(DesignOSListRowMetrics.titleSubtitleSpacing(for: .default) == 2)
  #expect(DesignOSListRowMetrics.contentSpacing(for: custom) == 10)
  #expect(DesignOSListRowMetrics.titleSubtitleSpacing(for: custom) == 2)
}

@Test("List row moves accessory content below the label at accessibility sizes")
func designOSListRowAccessibilityLayoutAxis() {
  #expect(DesignOSListRowMetrics.layoutAxis(for: .large) == .horizontal)
  #expect(
    DesignOSListRowMetrics.layoutAxis(for: .accessibility3) == .vertical
  )
}

private func commandRowProfile() throws -> DesignOSProfile {
  try DesignOSProfile(
    fontDesign: .expressive,
    titleSubtitleSpacing: 2,
    sidebarContentSpacing: 8,
    listRowContentSpacing: 10
  )
}
