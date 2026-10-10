import SwiftUI

/// A semantic section heading and optional caller-owned action with accessible reflow.
public struct DesignOSAppSectionHeader<Accessory: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private let title: LocalizedStringKey
  private let accessory: Accessory

  public init(_ title: LocalizedStringKey, @ViewBuilder accessory: () -> Accessory) {
    self.title = title
    self.accessory = accessory()
  }

  public var body: some View {
    let layout = DesignOSAppContentLayout.axis(for: dynamicTypeSize) == .vertical
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: style.metrics.itemSpacing))
      : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: style.metrics.itemSpacing))
    layout {
      Text(title)
        .font(DesignOSTypographyRole.title3.emphasized().font(profile: style.profile))
        .foregroundStyle(style.palette.ink.color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)
      accessory
    }
  }
}

extension DesignOSAppSectionHeader where Accessory == EmptyView {
  public init(_ title: LocalizedStringKey) {
    self.init(title, accessory: { EmptyView() })
  }
}

internal enum DesignOSAppContentLayout {
  static func axis(for dynamicTypeSize: DynamicTypeSize) -> Axis {
    dynamicTypeSize.isAccessibilitySize ? .vertical : .horizontal
  }
}
