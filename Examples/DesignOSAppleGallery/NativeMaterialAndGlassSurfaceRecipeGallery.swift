import SwiftUI

struct NativeMaterialAndGlassSurfaceRecipeGallery: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  var body: some View {
    Text(reduceTransparency ? "Opaque fallback" : "Native material")
      .padding()
      .background(
        reduceTransparency ? AnyShapeStyle(.background) : AnyShapeStyle(.regularMaterial),
        in: RoundedRectangle(cornerRadius: 16)
      )
  }
}
