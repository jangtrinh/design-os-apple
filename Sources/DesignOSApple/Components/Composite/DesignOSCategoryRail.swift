import SwiftUI

/// Titled horizontal category/media rail, with native item controls and an explicit empty slot.
///
/// This is the sole horizontal scroll owner for its items and is safe inside a vertical shell.
/// Stable caller IDs preserve item identity; selection and filtering remain app-owned. Supply
/// native Buttons or NavigationLinks as items, and localized header/empty content.
public struct DesignOSCategoryRail<Data: RandomAccessCollection, Header: View, Item: View, Empty: View>:
  View
where Data.Element: Identifiable {
  @Environment(\.designOSAppStyle) private var style
  private let data: Data
  private let header: Header
  private let item: (Data.Element) -> Item
  private let empty: Empty

  public init(
    _ data: Data,
    @ViewBuilder header: () -> Header,
    @ViewBuilder item: @escaping (Data.Element) -> Item,
    @ViewBuilder empty: () -> Empty
  ) {
    self.data = data
    self.header = header()
    self.item = item
    self.empty = empty()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
      header
      if data.isEmpty {
        empty
      } else {
        ScrollView(.horizontal) {
          LazyHStack(alignment: .top, spacing: style.metrics.itemSpacing) {
            ForEach(data) { element in item(element) }
          }
        }
      }
    }
  }
}
