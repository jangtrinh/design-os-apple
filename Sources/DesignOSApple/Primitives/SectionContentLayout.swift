import SwiftUI

/// Arranges section label content while native `Section` and `List` own container metrics.
package struct SectionContentLayout<Title: View, Trailing: View>: View {
  private let title: Title
  private let trailing: Trailing

  package init(
    @ViewBuilder title: () -> Title,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.title = title()
    self.trailing = trailing()
  }

  package var body: some View {
    HStack(spacing: 8) {
      title
        .frame(maxWidth: .infinity, alignment: .leading)

      AccessorySlotLayout {
        trailing
      }
    }
  }
}
