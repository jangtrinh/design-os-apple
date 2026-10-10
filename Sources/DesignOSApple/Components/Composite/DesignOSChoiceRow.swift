import SwiftUI

/// Choice description and an independently accessible native selection control.
///
/// Supply a real Toggle, Picker, Button or native List selection accessory. No row-wide gesture
/// or implicit checkmark is installed. Media remains caller-owned; narrow widths and accessibility
/// sizes reflow the same control rather than replacing it with a second view instance.
public struct DesignOSChoiceRow<Leading: View, Description: View, Control: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.layoutDirection) private var layoutDirection
  private let leading: Leading
  private let description: Description
  private let control: Control

  public init(
    @ViewBuilder leading: () -> Leading,
    @ViewBuilder description: () -> Description,
    @ViewBuilder control: () -> Control
  ) {
    self.leading = leading()
    self.description = description()
    self.control = control()
  }

  public var body: some View {
    DesignOSEditorialAdaptiveRowLayout(
      spacing: style.metrics.itemSpacing,
      accessibilitySize: dynamicTypeSize.isAccessibilitySize,
      layoutDirection: layoutDirection
    ) {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { leading }
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { description }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { control }
    }
  }
}
