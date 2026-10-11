import SwiftUI

/// Record/receipt summary, optional credential representation, details and local actions.
///
/// The app owns safe display and accessibility of QR/barcodes, sensitive fields and sharing.
/// This screen neither generates valid credentials nor makes a payment or authorization claim.
public struct DesignOSRecordDetailScreen<
  Summary: View, Credential: View, Details: View, Actions: View
>: View {
  @Environment(\.designOSAppStyle) private var style
  private let summary: Summary
  private let credential: Credential
  private let details: Details
  private let actions: Actions

  public init(
    @ViewBuilder summary: () -> Summary,
    @ViewBuilder credential: () -> Credential,
    @ViewBuilder details: () -> Details,
    @ViewBuilder actions: () -> Actions
  ) {
    self.summary = summary()
    self.credential = credential()
    self.details = details()
    self.actions = actions()
  }

  public var body: some View {
    DesignOSFlatScrollShell {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        summary
        credential
        details
        actions
      }
    }
  }
}
