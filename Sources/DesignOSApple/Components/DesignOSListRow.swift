import SwiftUI

/// Caller-owned list-row content that preserves native container and interaction ownership.
public struct DesignOSListRow<Leading: View, Title: View, Subtitle: View, Trailing: View>: View {
  @Environment(\.designOSProfile) private var profile
  private let leading: Leading
  private let title: Title
  private let subtitle: Subtitle
  private let trailing: Trailing

  /// Creates a row-content composition with leading, title, subtitle, and trailing slots.
  public init(
    @ViewBuilder _ leading: () -> Leading,
    @ViewBuilder title: () -> Title,
    @ViewBuilder subtitle: () -> Subtitle,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.leading = leading()
    self.title = title()
    self.subtitle = subtitle()
    self.trailing = trailing()
  }

  public var body: some View {
    HStack(alignment: .center, spacing: DesignOSListRowMetrics.contentSpacing(for: profile)) {
      SymbolContent(scale: .regular, kind: .symbol) {
        leading
      }

      SectionContentLayout {
        VStack(
          alignment: .leading, spacing: DesignOSListRowMetrics.titleSubtitleSpacing(for: profile)
        ) {
          title
          subtitle
            .foregroundStyle(DesignOSListRowStyle.secondaryContentRole(for: profile).color)
        }
      } trailing: {
        trailing
      }
    }
  }
}

internal enum DesignOSListRowStyle {
  static func secondaryContentRole(for profile: DesignOSProfile) -> DesignOSColorRole {
    profile.semanticColors.secondaryContent
  }
}

internal enum DesignOSListRowMetrics {
  static func contentSpacing(for profile: DesignOSProfile) -> CGFloat {
    profile.spacing.listRowContent
  }

  static func titleSubtitleSpacing(for profile: DesignOSProfile) -> CGFloat {
    profile.spacing.titleSubtitle
  }
}

extension DesignOSListRow where Leading == EmptyView {
  /// Creates row content without a leading slot.
  public init(
    @ViewBuilder title: () -> Title,
    @ViewBuilder subtitle: () -> Subtitle,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.init({ EmptyView() }, title: title, subtitle: subtitle, trailing: trailing)
  }
}

extension DesignOSListRow where Leading == EmptyView, Subtitle == EmptyView {
  /// Creates row content with title and trailing slots.
  public init(
    @ViewBuilder title: () -> Title,
    @ViewBuilder trailing: () -> Trailing
  ) {
    self.init(
      { EmptyView() },
      title: title,
      subtitle: { EmptyView() },
      trailing: trailing
    )
  }
}

extension DesignOSListRow
where Leading == EmptyView, Subtitle == EmptyView, Trailing == EmptyView {
  /// Creates title-only row content.
  public init(@ViewBuilder _ title: () -> Title) {
    self.init(
      { EmptyView() },
      title: title,
      subtitle: { EmptyView() },
      trailing: { EmptyView() }
    )
  }
}
