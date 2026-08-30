import DesignOSApple
import SwiftUI

struct PlatformSemanticColorGallery: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Resolved by the active platform")
        .foregroundStyle(DesignOSColorRole.labelPrimary.color)
      Text("Change appearance or contrast; no literal replacement is cached.")
        .foregroundStyle(DesignOSColorRole.labelSecondary.color)
    }
  }
}
