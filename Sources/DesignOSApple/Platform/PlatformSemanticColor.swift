import SwiftUI

#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#else
  #error("DesignOSApple supports iOS/iPadOS and macOS only")
#endif
extension DesignOSColorRole {
  /// The adaptive platform color for this semantic role.
  public var color: Color {
    PlatformSemanticColor.resolve(self)
  }
}
internal enum PlatformSemanticColor {
  static func resolve(_ role: DesignOSColorRole) -> Color {
    resolve(nativeReference(for: role))
  }
  #if os(iOS)
    internal enum NativeReference: Equatable, Sendable {
      case label, secondaryLabel, tertiaryLabel, quaternaryLabel
      case systemBackground, secondarySystemBackground, tertiarySystemBackground
      case systemGroupedBackground, secondarySystemGroupedBackground,
        tertiarySystemGroupedBackground
      case systemFill, secondarySystemFill, tertiarySystemFill, quaternarySystemFill
      case separator, systemRed, systemOrange, systemYellow, systemGreen, systemMint
      case systemTeal, systemCyan, systemBlue, systemIndigo, systemPurple, systemPink
      case systemBrown, systemGray, black, white, systemGray2, systemGray3, systemGray4
      case systemGray5, systemGray6, opaqueSeparator
    }
    internal enum IOSReference: CaseIterable, Equatable, Sendable {
      case black, white, gray2, gray3, gray4, gray5, gray6, opaqueSeparator
    }

    static func nativeReference(for role: DesignOSColorRole) -> NativeReference {
      switch role.identifier {
      case .labelPrimary: .label
      case .labelSecondary: .secondaryLabel
      case .labelTertiary: .tertiaryLabel
      case .labelQuaternary: .quaternaryLabel
      case .backgroundPrimary: .systemBackground
      case .backgroundSecondary: .secondarySystemBackground
      case .backgroundTertiary: .tertiarySystemBackground
      case .groupedBackgroundPrimary: .systemGroupedBackground
      case .groupedBackgroundSecondary: .secondarySystemGroupedBackground
      case .groupedBackgroundTertiary: .tertiarySystemGroupedBackground
      case .fillPrimary: .systemFill
      case .fillSecondary: .secondarySystemFill
      case .fillTertiary: .tertiarySystemFill
      case .fillQuaternary: .quaternarySystemFill
      case .separator: .separator
      case .red: .systemRed
      case .orange: .systemOrange
      case .yellow: .systemYellow
      case .green: .systemGreen
      case .mint: .systemMint
      case .teal: .systemTeal
      case .cyan: .systemCyan
      case .blue: .systemBlue
      case .indigo: .systemIndigo
      case .purple: .systemPurple
      case .pink: .systemPink
      case .brown: .systemBrown
      case .gray: .systemGray
      }
    }

    static func nativeReference(for reference: IOSReference) -> NativeReference {
      switch reference {
      case .black: .black
      case .white: .white
      case .gray2: .systemGray2
      case .gray3: .systemGray3
      case .gray4: .systemGray4
      case .gray5: .systemGray5
      case .gray6: .systemGray6
      case .opaqueSeparator: .opaqueSeparator
      }
    }

    static func resolve(_ reference: IOSReference) -> Color {
      resolve(nativeReference(for: reference))
    }

    static func resolve(_ reference: NativeReference) -> Color {
      switch reference {
      case .label: Color(uiColor: .label)
      case .secondaryLabel: Color(uiColor: .secondaryLabel)
      case .tertiaryLabel: Color(uiColor: .tertiaryLabel)
      case .quaternaryLabel: Color(uiColor: .quaternaryLabel)
      case .systemBackground: Color(uiColor: .systemBackground)
      case .secondarySystemBackground: Color(uiColor: .secondarySystemBackground)
      case .tertiarySystemBackground: Color(uiColor: .tertiarySystemBackground)
      case .systemGroupedBackground: Color(uiColor: .systemGroupedBackground)
      case .secondarySystemGroupedBackground: Color(uiColor: .secondarySystemGroupedBackground)
      case .tertiarySystemGroupedBackground: Color(uiColor: .tertiarySystemGroupedBackground)
      case .systemFill: Color(uiColor: .systemFill)
      case .secondarySystemFill: Color(uiColor: .secondarySystemFill)
      case .tertiarySystemFill: Color(uiColor: .tertiarySystemFill)
      case .quaternarySystemFill: Color(uiColor: .quaternarySystemFill)
      case .separator: Color(uiColor: .separator)
      case .systemRed: Color(uiColor: .systemRed)
      case .systemOrange: Color(uiColor: .systemOrange)
      case .systemYellow: Color(uiColor: .systemYellow)
      case .systemGreen: Color(uiColor: .systemGreen)
      case .systemMint: Color(uiColor: .systemMint)
      case .systemTeal: Color(uiColor: .systemTeal)
      case .systemCyan: Color(uiColor: .systemCyan)
      case .systemBlue: Color(uiColor: .systemBlue)
      case .systemIndigo: Color(uiColor: .systemIndigo)
      case .systemPurple: Color(uiColor: .systemPurple)
      case .systemPink: Color(uiColor: .systemPink)
      case .systemBrown: Color(uiColor: .systemBrown)
      case .systemGray: Color(uiColor: .systemGray)
      case .black: Color(uiColor: .black)
      case .white: Color(uiColor: .white)
      case .systemGray2: Color(uiColor: .systemGray2)
      case .systemGray3: Color(uiColor: .systemGray3)
      case .systemGray4: Color(uiColor: .systemGray4)
      case .systemGray5: Color(uiColor: .systemGray5)
      case .systemGray6: Color(uiColor: .systemGray6)
      case .opaqueSeparator: Color(uiColor: .opaqueSeparator)
      }
    }
  #elseif os(macOS)
    internal enum NativeReference: Equatable, Sendable {
      case labelColor, secondaryLabelColor, tertiaryLabelColor, quaternaryLabelColor
      case windowBackgroundColor, controlBackgroundColor, underPageBackgroundColor
      case systemFill, secondarySystemFill, tertiarySystemFill, quaternarySystemFill
      case separatorColor, systemRed, systemOrange, systemYellow, systemGreen, systemMint
      case systemTeal, systemCyan, systemBlue, systemIndigo, systemPurple, systemPink
      case systemBrown, systemGray
    }

    static func nativeReference(for role: DesignOSColorRole) -> NativeReference {
      switch role.identifier {
      case .labelPrimary: .labelColor
      case .labelSecondary: .secondaryLabelColor
      case .labelTertiary: .tertiaryLabelColor
      case .labelQuaternary: .quaternaryLabelColor
      case .backgroundPrimary: .windowBackgroundColor
      case .backgroundSecondary: .controlBackgroundColor
      case .backgroundTertiary: .underPageBackgroundColor
      case .groupedBackgroundPrimary: .controlBackgroundColor
      case .groupedBackgroundSecondary: .windowBackgroundColor
      case .groupedBackgroundTertiary: .underPageBackgroundColor
      case .fillPrimary: .systemFill
      case .fillSecondary: .secondarySystemFill
      case .fillTertiary: .tertiarySystemFill
      case .fillQuaternary: .quaternarySystemFill
      case .separator: .separatorColor
      case .red: .systemRed
      case .orange: .systemOrange
      case .yellow: .systemYellow
      case .green: .systemGreen
      case .mint: .systemMint
      case .teal: .systemTeal
      case .cyan: .systemCyan
      case .blue: .systemBlue
      case .indigo: .systemIndigo
      case .purple: .systemPurple
      case .pink: .systemPink
      case .brown: .systemBrown
      case .gray: .systemGray
      }
    }

    static func resolve(_ reference: NativeReference) -> Color {
      switch reference {
      case .labelColor: Color(nsColor: .labelColor)
      case .secondaryLabelColor: Color(nsColor: .secondaryLabelColor)
      case .tertiaryLabelColor: Color(nsColor: .tertiaryLabelColor)
      case .quaternaryLabelColor: Color(nsColor: .quaternaryLabelColor)
      case .windowBackgroundColor: Color(nsColor: .windowBackgroundColor)
      case .controlBackgroundColor: Color(nsColor: .controlBackgroundColor)
      case .underPageBackgroundColor: Color(nsColor: .underPageBackgroundColor)
      case .systemFill: Color(nsColor: .systemFill)
      case .secondarySystemFill: Color(nsColor: .secondarySystemFill)
      case .tertiarySystemFill: Color(nsColor: .tertiarySystemFill)
      case .quaternarySystemFill: Color(nsColor: .quaternarySystemFill)
      case .separatorColor: Color(nsColor: .separatorColor)
      case .systemRed: Color(nsColor: .systemRed)
      case .systemOrange: Color(nsColor: .systemOrange)
      case .systemYellow: Color(nsColor: .systemYellow)
      case .systemGreen: Color(nsColor: .systemGreen)
      case .systemMint: Color(nsColor: .systemMint)
      case .systemTeal: Color(nsColor: .systemTeal)
      case .systemCyan: Color(nsColor: .systemCyan)
      case .systemBlue: Color(nsColor: .systemBlue)
      case .systemIndigo: Color(nsColor: .systemIndigo)
      case .systemPurple: Color(nsColor: .systemPurple)
      case .systemPink: Color(nsColor: .systemPink)
      case .systemBrown: Color(nsColor: .systemBrown)
      case .systemGray: Color(nsColor: .systemGray)
      }
    }
  #endif
}
