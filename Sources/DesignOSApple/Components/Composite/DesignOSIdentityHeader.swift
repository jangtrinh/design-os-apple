import SwiftUI

/// Reflowing identity, descriptive text and local actions without a mandatory card or image.
///
/// The caller supplies image accessibility, heading traits and native actions. At accessibility
/// text sizes, the identity moves above its text. No fixed text height or truncation is imposed.
public struct DesignOSIdentityHeader<Identity: View, Title: View, Metadata: View, Actions: View>:
  View
{
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private let identity: Identity
  private let title: Title
  private let metadata: Metadata
  private let actions: Actions

  public init(
    @ViewBuilder identity: () -> Identity,
    @ViewBuilder title: () -> Title,
    @ViewBuilder metadata: () -> Metadata,
    @ViewBuilder actions: () -> Actions
  ) {
    self.identity = identity()
    self.title = title()
    self.metadata = metadata()
    self.actions = actions()
  }

  public var body: some View {
    let layout =
      DesignOSAppContentLayout.axis(for: dynamicTypeSize) == .vertical
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: style.metrics.itemSpacing))
      : AnyLayout(HStackLayout(alignment: .top, spacing: style.metrics.itemSpacing))
    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
      layout {
        identity
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
          title
          metadata
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      actions
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

extension DesignOSIdentityHeader where Identity == EmptyView, Actions == EmptyView {
  public init(@ViewBuilder title: () -> Title, @ViewBuilder metadata: () -> Metadata) {
    self.init(identity: { EmptyView() }, title: title, metadata: metadata, actions: { EmptyView() })
  }
}
