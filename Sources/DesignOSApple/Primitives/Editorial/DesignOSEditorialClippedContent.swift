import SwiftUI

/// Clips the content's actual finite frame, rather than a larger transparent layout wrapper.
internal struct DesignOSEditorialClippedContent<Content: View, Clip: Shape>: View {
  let size: CGSize
  let shape: Clip
  let content: Content

  var body: some View {
    content
      .frame(
        width: DesignOSEditorialGeometry.length(size.width),
        height: DesignOSEditorialGeometry.length(size.height)
      )
      .clipped()
      .clipShape(shape)
  }
}
