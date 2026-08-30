import DesignOSApple
import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Sidebar row composes a label and caller-owned accessory")
@MainActor
func designOSSidebarRowCompiles() {
  let row = DesignOSSidebarRow {
    Label("Downloads", systemImage: "arrow.down.circle")
  } accessory: {
    Text("4")
  }

  #expect(String(reflecting: type(of: row)).contains("DesignOSSidebarRow"))
}

@Test("Sidebar row supports label-only content")
@MainActor
func designOSSidebarRowLabelOnlyCompiles() {
  let row = DesignOSSidebarRow {
    Label("Library", systemImage: "books.vertical")
  }

  #expect(String(reflecting: type(of: row)).contains("DesignOSSidebarRow"))
}

@Test("Sidebar row profile metric follows a custom profile independently")
func designOSSidebarRowProfileMetric() throws {
  let custom = try commandRowProfile()
  #expect(DesignOSSidebarRowMetrics.contentSpacing(for: .default) == 8)
  #expect(DesignOSSidebarRowMetrics.contentSpacing(for: custom) == 8)
}

private func commandRowProfile() throws -> DesignOSProfile {
  try DesignOSProfile(
    fontDesign: .expressive,
    titleSubtitleSpacing: 2,
    sidebarContentSpacing: 8,
    listRowContentSpacing: 10
  )
}
