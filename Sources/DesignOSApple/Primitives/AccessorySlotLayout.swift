import SwiftUI

/// Groups caller-owned row accessories without recreating native row controls or state.
package struct AccessorySlotLayout<Content: View>: View {
  private let spacing: CGFloat
  private let content: Content

  package init(
    spacing: CGFloat = 8,
    @ViewBuilder content: () -> Content
  ) {
    self.spacing = spacing
    self.content = content()
  }

  package var body: some View {
    HStack(spacing: spacing) {
      content
    }
  }
}
