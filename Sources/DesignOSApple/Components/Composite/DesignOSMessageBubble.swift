import SwiftUI

/// Directional message content with optional reply context and persistent delivery metadata.
///
/// The native text/media and context-menu actions remain caller-owned. This component only
/// aligns and groups content: no invented sender, delivery state, network work or row gesture.
/// Incoming/outgoing tones reuse adaptive surfaces, and metadata stays outside the bubble.
/// For media filling this surface, derive its inner corner radius from the style surfaceRadius
/// and actual contentInset using DesignOSCornerGeometry, rather than reusing the outer radius.
public struct DesignOSMessageBubble<Reply: View, Content: View, Metadata: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let isOutgoing: Bool
  private let reply: Reply
  private let content: Content
  private let metadata: Metadata

  public init(
    isOutgoing: Bool,
    @ViewBuilder reply: () -> Reply,
    @ViewBuilder content: () -> Content,
    @ViewBuilder metadata: () -> Metadata
  ) {
    self.isOutgoing = isOutgoing
    self.reply = reply()
    self.content = content()
    self.metadata = metadata()
  }

  public var body: some View {
    VStack(alignment: isOutgoing ? .trailing : .leading, spacing: style.metrics.itemSpacing) {
      DesignOSAppSurface(tone: isOutgoing ? .standard : .subtle) {
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
          reply
          content
        }
        .fixedSize(horizontal: false, vertical: true)
      }
      metadata
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: isOutgoing ? .trailing : .leading)
  }
}

extension DesignOSMessageBubble where Reply == EmptyView {
  public init(
    isOutgoing: Bool,
    @ViewBuilder content: () -> Content,
    @ViewBuilder metadata: () -> Metadata
  ) {
    self.init(isOutgoing: isOutgoing, reply: { EmptyView() }, content: content, metadata: metadata)
  }
}
