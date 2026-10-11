import SwiftUI

/// One native grouped Form. Native Sections own their surfaces and control behavior.
///
/// Supply Sections containing actual controls; do not nest DesignOSFieldGroup, custom cards,
/// Lists or ScrollViews. Routing, validation, focus and persistence belong to the app.
public struct DesignOSGroupedFormShell<Content: View>: View {
  private let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    Form { content }
      .formStyle(.grouped)
  }
}
