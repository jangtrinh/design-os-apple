import SwiftUI

/// Label/value/accessory content that reflows without replacing caller-owned native controls.
///
/// The row owns no selection, navigation, gesture, validation, or focus. A native input supplied
/// in the value slot still needs its own programmatic label. Value and accessory accessibility
/// remain separate; this container does not combine or hide their elements.
public struct DesignOSLabeledValueRow<Value: View, Accessory: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.layoutDirection) private var layoutDirection
  private let title: LocalizedStringKey
  private let value: Value
  private let accessory: Accessory

  public init(
    _ title: LocalizedStringKey,
    @ViewBuilder value: () -> Value,
    @ViewBuilder accessory: () -> Accessory
  ) {
    self.title = title
    self.value = value()
    self.accessory = accessory()
  }

  public var body: some View {
    DesignOSEditorialAdaptiveRowLayout(
      spacing: style.metrics.itemSpacing,
      accessibilitySize: dynamicTypeSize.isAccessibilitySize,
      layoutDirection: layoutDirection
    ) {
      Text(title)
        .font(DesignOSTypographyRole.body.font(profile: style.profile))
        .foregroundStyle(style.palette.secondaryInk.color)
        .fixedSize(horizontal: false, vertical: true)
      value
        .font(DesignOSTypographyRole.body.font(profile: style.profile))
        .foregroundStyle(style.palette.ink.color)
        .frame(maxWidth: .infinity, alignment: .leading)
      accessory
    }
  }
}

extension DesignOSLabeledValueRow where Accessory == EmptyView {
  public init(_ title: LocalizedStringKey, @ViewBuilder value: () -> Value) {
    self.init(title, value: value, accessory: { EmptyView() })
  }
}
