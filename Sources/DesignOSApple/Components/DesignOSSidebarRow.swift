import SwiftUI

/// Caller-owned sidebar-row content that leaves selection and hierarchy to native containers.
public struct DesignOSSidebarRow<Label: View, Accessory: View>: View {
  @Environment(\.designOSProfile) private var profile
  private let label: Label
  private let accessory: Accessory

  /// Creates sidebar-row content with label and trailing accessory slots.
  public init(
    @ViewBuilder _ label: () -> Label,
    @ViewBuilder accessory: () -> Accessory
  ) {
    self.label = label()
    self.accessory = accessory()
  }

  public var body: some View {
    HStack(spacing: DesignOSSidebarRowMetrics.contentSpacing(for: profile)) {
      label
        .frame(maxWidth: .infinity, alignment: .leading)

      AccessorySlotLayout {
        accessory
      }
    }
  }
}

internal enum DesignOSSidebarRowMetrics {
  static func contentSpacing(for profile: DesignOSProfile) -> CGFloat {
    profile.spacing.sidebarContent
  }
}

extension DesignOSSidebarRow where Accessory == EmptyView {
  /// Creates sidebar-row content without an accessory.
  public init(@ViewBuilder _ label: () -> Label) {
    self.init(label, accessory: { EmptyView() })
  }
}
