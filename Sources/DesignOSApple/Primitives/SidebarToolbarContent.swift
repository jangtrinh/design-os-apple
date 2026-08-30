import SwiftUI

/// Separates sidebar toolbar content without drawing window controls or owning actions.
package struct SidebarToolbarContent<Leading: View, Trailing: View>: View {
  private let leading: Leading
  private let trailing: Trailing

  package init(
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.leading = leading()
    self.trailing = trailing()
  }

  package var body: some View {
    HStack(spacing: 12) {
      leading
      Spacer(minLength: 8)
      AccessorySlotLayout(spacing: 24) {
        trailing
      }
    }
  }
}
