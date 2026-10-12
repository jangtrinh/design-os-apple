import SwiftUI

/// A grouped record identity/status header with readable native labeled facts beneath.
///
/// The caller supplies safe identifier text, actual status and facts such as LabeledContent or
/// DesignOSLabeledValueRow. It does not generate credentials, infer payment status or install a
/// sharing action. Use outside native Form groups to avoid card-in-card structure.
public struct DesignOSRecordSummary<Identifier: View, Status: View, Facts: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private let identifier: Identifier
  private let status: Status
  private let facts: Facts

  public init(
    @ViewBuilder identifier: () -> Identifier,
    @ViewBuilder status: () -> Status,
    @ViewBuilder facts: () -> Facts
  ) {
    self.identifier = identifier()
    self.status = status()
    self.facts = facts()
  }

  public var body: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: style.metrics.itemSpacing))
      : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: style.metrics.itemSpacing))
    DesignOSAppSurface {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        layout {
          VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { identifier }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
          VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { status }
        }
        Divider()
        facts
      }
    }
  }
}
