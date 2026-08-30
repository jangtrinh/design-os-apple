import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Every typography role has a semantic font projection")
func publicTypographyRolesResolve() {
  for (role, _) in typographyDescriptors {
    acceptsFont(role.font)
  }
}

@Test("Every typography role selects its semantic descriptor")
func typographyDescriptorTableIsExact() {
  #expect(typographyDescriptors.count == 11)
  for (role, descriptor) in typographyDescriptors {
    #expect(PlatformTypography.descriptor(for: role) == descriptor)
  }
}

@Test("Typography descriptor state selects native font modifiers")
func typographyDescriptorStatesSelectNativeModifiers() {
  let body = DesignOSTypographyRole.body
  let cases: [(DesignOSTypographyRole, [PlatformTypography.Modifier])] = [
    (body, []), (body.emphasized(), [.bold]), (body.italic(), [.italic]),
    (body.emphasized().italic(), [.bold, .italic]),
  ]

  for (role, modifiers) in cases {
    let descriptor = PlatformTypography.descriptor(for: role)
    #expect(PlatformTypography.modifiers(for: descriptor) == modifiers)
    acceptsFont(PlatformTypography.resolve(role))
  }
}

private func acceptsFont(_: Font) {}

private let typographyDescriptors: [(DesignOSTypographyRole, PlatformTypography.Descriptor)] = [
  (.largeTitle, .init(style: .largeTitle, isEmphasized: false, isItalic: false)),
  (.title, .init(style: .title, isEmphasized: false, isItalic: false)),
  (.title2, .init(style: .title2, isEmphasized: false, isItalic: false)),
  (.title3, .init(style: .title3, isEmphasized: false, isItalic: false)),
  (.headline, .init(style: .headline, isEmphasized: false, isItalic: false)),
  (.subheadline, .init(style: .subheadline, isEmphasized: false, isItalic: false)),
  (.body, .init(style: .body, isEmphasized: false, isItalic: false)),
  (.callout, .init(style: .callout, isEmphasized: false, isItalic: false)),
  (.footnote, .init(style: .footnote, isEmphasized: false, isItalic: false)),
  (.caption, .init(style: .caption, isEmphasized: false, isItalic: false)),
  (.caption2, .init(style: .caption2, isEmphasized: false, isItalic: false)),
]
