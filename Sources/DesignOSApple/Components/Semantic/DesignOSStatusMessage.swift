import SwiftUI

/// Inline status content with optional caller-owned icon and real native actions.
///
/// Use for a meaningful empty, error, busy, or result message inside a larger composition.
/// The app chooses the state, copy, recovery action, and any accessibility announcement. This
/// view does not start work, dismiss itself, invent a severity, or hide the supplied actions.
public struct DesignOSStatusMessage<Icon: View, Actions: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let title: LocalizedStringKey
  private let message: LocalizedStringKey?
  private let icon: Icon
  private let actions: Actions

  public init(
    _ title: LocalizedStringKey,
    message: LocalizedStringKey? = nil,
    @ViewBuilder icon: () -> Icon,
    @ViewBuilder actions: () -> Actions
  ) {
    self.title = title
    self.message = message
    self.icon = icon()
    self.actions = actions()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
      icon
      VStack(alignment: .leading, spacing: style.profile.spacing.titleSubtitle) {
        Text(title)
          .font(DesignOSTypographyRole.headline.font(profile: style.profile))
          .foregroundStyle(style.palette.ink.color)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityAddTraits(.isHeader)
        if let message {
          Text(message)
            .font(DesignOSTypographyRole.body.font(profile: style.profile))
            .foregroundStyle(style.palette.secondaryInk.color)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      actions
    }
  }
}

extension DesignOSStatusMessage where Icon == EmptyView {
  public init(
    _ title: LocalizedStringKey,
    message: LocalizedStringKey? = nil,
    @ViewBuilder actions: () -> Actions
  ) {
    self.init(title, message: message, icon: { EmptyView() }, actions: actions)
  }
}

extension DesignOSStatusMessage where Actions == EmptyView {
  public init(
    _ title: LocalizedStringKey,
    message: LocalizedStringKey? = nil,
    @ViewBuilder icon: () -> Icon
  ) {
    self.init(title, message: message, icon: icon, actions: { EmptyView() })
  }
}

extension DesignOSStatusMessage where Icon == EmptyView, Actions == EmptyView {
  public init(_ title: LocalizedStringKey, message: LocalizedStringKey? = nil) {
    self.init(title, message: message, icon: { EmptyView() }, actions: { EmptyView() })
  }
}
