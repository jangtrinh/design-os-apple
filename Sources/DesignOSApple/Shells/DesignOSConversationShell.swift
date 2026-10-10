import SwiftUI

/// One scrollable conversation with an anchored, caller-owned native composer.
///
/// The proxy is available for explicit app-owned scroll policy; this shell never jumps on
/// arrival, steals focus or sends messages. Give messages stable IDs. Composer controls keep
/// native keyboard avoidance, and should remain compact enough to leave readable history.
public struct DesignOSConversationShell<Messages: View, Composer: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let messages: (ScrollViewProxy) -> Messages
  private let composer: Composer

  public init(
    @ViewBuilder messages: @escaping (ScrollViewProxy) -> Messages,
    @ViewBuilder composer: () -> Composer
  ) {
    self.messages = messages
    self.composer = composer()
  }

  public var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        messages(proxy)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(style.metrics.pageInset)
      }
      .safeAreaInset(edge: .bottom, spacing: 0) {
        composer
          .padding(style.metrics.contentInset)
          .frame(maxWidth: .infinity)
          .background(style.palette.canvas.color)
      }
    }
    .background(style.palette.canvas.color)
  }
}
