import SwiftUI

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

struct LocalDemoRGB {
  let red: Double
  let green: Double
  let blue: Double
}

extension Color {
  static func localDemoAdaptive(light: LocalDemoRGB, dark: LocalDemoRGB) -> Color {
    #if canImport(UIKit)
      Color(
        uiColor: UIColor { traits in
          platformColor(
            traits.userInterfaceStyle == .dark ? dark : light
          )
        }
      )
    #elseif canImport(AppKit)
      Color(
        nsColor: NSColor(name: nil) { appearance in
          platformColor(
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
          )
        }
      )
    #else
      Color(red: light.red, green: light.green, blue: light.blue)
    #endif
  }
}

#if canImport(UIKit)
  private func platformColor(_ value: LocalDemoRGB) -> UIColor {
    UIColor(red: value.red, green: value.green, blue: value.blue, alpha: 1)
  }
#elseif canImport(AppKit)
  private func platformColor(_ value: LocalDemoRGB) -> NSColor {
    NSColor(srgbRed: value.red, green: value.green, blue: value.blue, alpha: 1)
  }
#endif
