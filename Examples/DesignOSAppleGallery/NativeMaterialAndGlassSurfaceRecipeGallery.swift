import SwiftUI

struct NativeMaterialAndGlassSurfaceRecipeGallery: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  var body: some View {
    surface(for: Surface.resolve(
      reduceTransparency: reduceTransparency,
      supportsGlass: Self.supportsGlass
    ))
  }

  /// The compiler gate matches Xcode 26's Swift toolchain; the runtime gate
  /// preserves the Gallery's iOS 17 and macOS 14 deployment floors.
  static var supportsGlass: Bool {
    #if compiler(>=6.2)
    if #available(iOS 26, macOS 26, *) { return true }
    #endif
    return false
  }

  @ViewBuilder
  private func surface(for selection: Surface) -> some View {
    switch selection {
    case .opaque:
      surfaceLabel(.opaque)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    case .material:
      materialSurface
    case .glass:
      #if compiler(>=6.2)
      if #available(iOS 26, macOS 26, *) {
        surfaceLabel(.glass)
          .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
      } else {
        materialSurface
      }
      #else
      materialSurface
      #endif
    }
  }

  private var materialSurface: some View {
    surfaceLabel(.material)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
  }

  private func surfaceLabel(_ selection: Surface) -> some View {
    Text(selection.label)
      .padding()
  }

  enum Surface: Equatable {
    case opaque
    case material
    case glass

    static func resolve(reduceTransparency: Bool, supportsGlass: Bool) -> Self {
      if reduceTransparency { return .opaque }
      return supportsGlass ? .glass : .material
    }

    var label: String {
      switch self {
      case .opaque: "Opaque fallback · Reduce Transparency"
      case .material: "Native material · Glass unavailable"
      case .glass: "Native Liquid Glass"
      }
    }
  }
}
