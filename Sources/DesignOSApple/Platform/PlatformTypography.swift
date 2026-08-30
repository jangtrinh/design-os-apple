import SwiftUI

extension DesignOSTypographyRole {
  /// The platform-native semantic font for this typography role.
  public var font: Font {
    PlatformTypography.resolve(self)
  }

  /// The platform-native semantic font for this role under an environment profile.
  public func font(profile: DesignOSProfile) -> Font {
    PlatformTypography.resolve(self, fontDesign: PlatformTypography.fontDesign(for: profile))
  }
}

internal enum PlatformTypography {
  static func fontDesign(for profile: DesignOSProfile) -> DesignOSFontDesign {
    profile.typography.fontDesign
  }

  internal struct Descriptor: Equatable, Sendable {
    internal enum Style: Equatable, Sendable {
      case largeTitle, title, title2, title3, headline, subheadline
      case body, callout, footnote, caption, caption2
    }

    let style: Style
    let isEmphasized: Bool
    let isItalic: Bool
  }

  internal enum Modifier: Equatable, Sendable {
    case bold
    case italic
  }

  static func descriptor(for role: DesignOSTypographyRole) -> Descriptor {
    Descriptor(
      style: style(for: role.identifier),
      isEmphasized: role.isEmphasized,
      isItalic: role.isItalic
    )
  }

  static func modifiers(for descriptor: Descriptor) -> [Modifier] {
    var modifiers: [Modifier] = []
    if descriptor.isEmphasized { modifiers.append(.bold) }
    if descriptor.isItalic { modifiers.append(.italic) }
    return modifiers
  }

  static func resolve(_ role: DesignOSTypographyRole) -> Font {
    resolve(role, fontDesign: .standard)
  }

  static func resolve(_ role: DesignOSTypographyRole, fontDesign: DesignOSFontDesign) -> Font {
    let descriptor = descriptor(for: role)
    var font = Font.system(
      textStyle(for: descriptor.style), design: platformDesign(for: fontDesign))
    for modifier in modifiers(for: descriptor) {
      switch modifier {
      case .bold: font = font.bold()
      case .italic: font = font.italic()
      }
    }
    return font
  }

  private static func style(for identifier: DesignOSTypographyRole.Identifier) -> Descriptor.Style {
    switch identifier {
    case .largeTitle: .largeTitle
    case .title: .title
    case .title2: .title2
    case .title3: .title3
    case .headline: .headline
    case .subheadline: .subheadline
    case .body: .body
    case .callout: .callout
    case .footnote: .footnote
    case .caption: .caption
    case .caption2: .caption2
    }
  }

  private static func textStyle(for style: Descriptor.Style) -> Font.TextStyle {
    switch style {
    case .largeTitle: .largeTitle
    case .title: .title
    case .title2: .title2
    case .title3: .title3
    case .headline: .headline
    case .subheadline: .subheadline
    case .body: .body
    case .callout: .callout
    case .footnote: .footnote
    case .caption: .caption
    case .caption2: .caption2
    }
  }

  private static func platformDesign(for design: DesignOSFontDesign) -> Font.Design {
    switch design {
    case .standard: .default
    case .expressive: .rounded
    }
  }
}
