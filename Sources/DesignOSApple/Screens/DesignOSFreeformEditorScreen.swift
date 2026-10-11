import SwiftUI

/// A real native TextEditor with caller-owned text, inline feedback and no outer scroll view.
///
/// Focus, cancellation, formatting and persistence stay in the app. TextEditor owns scrolling
/// and keyboard behavior. Supply an explicit accessible label; a placeholder is not a label.
public struct DesignOSFreeformEditorScreen<Feedback: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Binding private var text: String
  private let label: LocalizedStringKey
  private let feedback: Feedback

  public init(
    _ label: LocalizedStringKey,
    text: Binding<String>,
    @ViewBuilder feedback: () -> Feedback
  ) {
    self.label = label
    self._text = text
    self.feedback = feedback()
  }

  public var body: some View {
    DesignOSNativeHostShell {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        TextEditor(text: $text)
          .accessibilityLabel(Text(label))
          .scrollContentBackground(.hidden)
        feedback
      }
      .padding(style.metrics.pageInset)
    }
  }
}

extension DesignOSFreeformEditorScreen where Feedback == EmptyView {
  public init(_ label: LocalizedStringKey, text: Binding<String>) {
    self.init(label, text: text, feedback: { EmptyView() })
  }
}
