import DesignOSApple
import SwiftUI

struct DesignOSSurfaceRoleGallery: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Surface roles express intent only")
        .font(DesignOSTypographyRole.headline.font)
      Text("Native List, Form, sheet, popover, and window surfaces stay native.")
        .foregroundStyle(DesignOSColorRole.labelSecondary.color)
    }
    .padding()
    .background(.background, in: RoundedRectangle(cornerRadius: 16))
  }
}
