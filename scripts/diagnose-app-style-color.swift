import AppKit
import Foundation
import SwiftUI

// Compile this together with the production DesignOSAdaptiveColor.swift. No copied color policy.
@main
private struct AppStyleColorDiagnostic {
  @MainActor
  static func main() throws {
    let adaptive = try DesignOSAdaptiveColor(
      lightRGB: 0x16_1616,
      darkRGB: 0xCC_CCCC,
      increasedContrastLightRGB: 0x00_0000,
      increasedContrastDarkRGB: 0xFF_FFFF
    )
    let variants: [(NSAppearance.Name, ColorScheme, Bool)] = [
      (.aqua, .light, false),
      (.darkAqua, .dark, false),
      (.accessibilityHighContrastAqua, .light, true),
      (.accessibilityHighContrastDarkAqua, .dark, true),
    ]
    let names = variants.map(\.0)
    print("OS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
    print("System Increase Contrast: \(NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast)")
    for (name, scheme, increased) in variants {
      guard let appearance = NSAppearance(named: name) else {
        print("Unavailable appearance: \(name.rawValue)")
        continue
      }
      let expected = adaptive.resolvedRGB(dark: scheme == .dark, increasedContrast: increased)
      print("\nRequested: \(name.rawValue); actual name: \(appearance.name.rawValue)")
      print("bestMatch: \(appearance.bestMatch(from: names)?.rawValue ?? "nil")")
      print(String(format: "Expected: #%06X", expected))
      appearance.performAsCurrentDrawingAppearance {
        print("Drawing appearance: \(NSAppearance.currentDrawing().name.rawValue)")
        print("Production NSColor: \(components(adaptive.nativeColor))")
        print("Public Color -> NSColor round trip: \(components(NSColor(adaptive.color)))")
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        print("SwiftUI environment contrast (read-only): \(environment.colorSchemeContrast)")
        let resolved = adaptive.color.resolve(in: environment)
        print(
          "Public Color.resolve: \(resolved.red), \(resolved.green), \(resolved.blue), \(resolved.opacity)"
        )
      }
    }
  }

  private static func components(_ color: NSColor) -> String {
    guard let rgb = color.usingColorSpace(.sRGB) else { return "unresolved" }
    return String(
      format: "%.6f, %.6f, %.6f, %.6f",
      Double(rgb.redComponent), Double(rgb.greenComponent),
      Double(rgb.blueComponent), Double(rgb.alphaComponent)
    )
  }
}
