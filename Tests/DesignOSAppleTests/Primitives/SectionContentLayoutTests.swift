import DesignOSApple
import SwiftUI
import Testing

@Test("Section content keeps title and trailing content caller-owned")
@MainActor
func sectionContentLayoutCompiles() {
  acceptsView(
    SectionContentLayout {
      Text("Section heading")
    } trailing: {
      Text("Detail")
      Image(systemName: "chevron.down")
    }
  )
}

private func acceptsView(_: some View) {}
