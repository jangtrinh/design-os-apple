import SwiftUI

/// A semantic group of real controls on a custom scrolling canvas.
///
/// Header and footer stay outside one surface. Supply native fields, pickers and toggles;
/// this component owns no bindings, validation, focus or separators. Inside a native Form,
/// use Section instead so the platform owns grouping and row behavior.
public struct DesignOSFieldGroup<Header: View, Content: View, Footer: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let tone: DesignOSAppSurface<VStack<Content>>.Tone
  private let header: Header
  private let content: Content
  private let footer: Footer

  public init(
    tone: DesignOSAppSurface<VStack<Content>>.Tone = .standard,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer
  ) {
    self.tone = tone
    self.header = header()
    self.content = content()
    self.footer = footer()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
      header
      DesignOSAppSurface(tone: tone) {
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { content }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      footer
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

extension DesignOSFieldGroup where Header == EmptyView, Footer == EmptyView {
  public init(
    tone: DesignOSAppSurface<VStack<Content>>.Tone = .standard,
    @ViewBuilder content: () -> Content
  ) {
    self.init(tone: tone, header: { EmptyView() }, content: content, footer: { EmptyView() })
  }
}
