import SwiftUI

extension View {
  func localDemoRootIdentifier(_ identifier: String) -> some View {
    overlay(alignment: .topLeading) {
      Color.clear
        .frame(width: 1, height: 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Screen ready")
        .accessibilityIdentifier(identifier)
    }
  }
}
