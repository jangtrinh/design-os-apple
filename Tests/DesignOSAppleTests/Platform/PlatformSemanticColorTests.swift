import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Every public color role has a platform color projection")
func publicColorRolesResolve() {
  for (role, _) in semanticColorReferences {
    acceptsColor(role.color)
  }
}

@Test("Every public color role selects its native semantic reference")
func semanticColorReferenceTableIsExact() {
  #expect(semanticColorReferences.count == 28)
  for (role, reference) in semanticColorReferences {
    #expect(PlatformSemanticColor.nativeReference(for: role) == reference)
    acceptsColor(PlatformSemanticColor.resolve(reference))
  }
}

#if os(iOS)
  @Test("UIKit-only construction references select their native semantics")
  func iOSConstructionReferenceTableIsExact() {
    #expect(iOSConstructionReferences.count == 8)
    for (reference, nativeReference) in iOSConstructionReferences {
      #expect(PlatformSemanticColor.nativeReference(for: reference) == nativeReference)
      acceptsColor(PlatformSemanticColor.resolve(nativeReference))
    }
  }
#endif

private func acceptsColor(_: Color) {}

#if os(iOS)
  private let semanticColorReferences:
    [(DesignOSColorRole, PlatformSemanticColor.NativeReference)] = [
      (.labelPrimary, .label), (.labelSecondary, .secondaryLabel),
      (.labelTertiary, .tertiaryLabel), (.labelQuaternary, .quaternaryLabel),
      (.backgroundPrimary, .systemBackground), (.backgroundSecondary, .secondarySystemBackground),
      (.backgroundTertiary, .tertiarySystemBackground),
      (.groupedBackgroundPrimary, .systemGroupedBackground),
      (.groupedBackgroundSecondary, .secondarySystemGroupedBackground),
      (.groupedBackgroundTertiary, .tertiarySystemGroupedBackground),
      (.fillPrimary, .systemFill), (.fillSecondary, .secondarySystemFill),
      (.fillTertiary, .tertiarySystemFill), (.fillQuaternary, .quaternarySystemFill),
      (.separator, .separator), (.red, .systemRed), (.orange, .systemOrange),
      (.yellow, .systemYellow), (.green, .systemGreen), (.mint, .systemMint),
      (.teal, .systemTeal), (.cyan, .systemCyan), (.blue, .systemBlue),
      (.indigo, .systemIndigo), (.purple, .systemPurple), (.pink, .systemPink),
      (.brown, .systemBrown), (.gray, .systemGray),
    ]

  private let iOSConstructionReferences:
    [(PlatformSemanticColor.IOSReference, PlatformSemanticColor.NativeReference)] = [
      (.black, .black), (.white, .white), (.gray2, .systemGray2), (.gray3, .systemGray3),
      (.gray4, .systemGray4), (.gray5, .systemGray5), (.gray6, .systemGray6),
      (.opaqueSeparator, .opaqueSeparator),
    ]
#elseif os(macOS)
  private let semanticColorReferences:
    [(DesignOSColorRole, PlatformSemanticColor.NativeReference)] = [
      (.labelPrimary, .labelColor), (.labelSecondary, .secondaryLabelColor),
      (.labelTertiary, .tertiaryLabelColor), (.labelQuaternary, .quaternaryLabelColor),
      (.backgroundPrimary, .windowBackgroundColor), (.backgroundSecondary, .controlBackgroundColor),
      (.backgroundTertiary, .underPageBackgroundColor),
      (.groupedBackgroundPrimary, .controlBackgroundColor),
      (.groupedBackgroundSecondary, .windowBackgroundColor),
      (.groupedBackgroundTertiary, .underPageBackgroundColor),
      (.fillPrimary, .systemFill), (.fillSecondary, .secondarySystemFill),
      (.fillTertiary, .tertiarySystemFill), (.fillQuaternary, .quaternarySystemFill),
      (.separator, .separatorColor), (.red, .systemRed), (.orange, .systemOrange),
      (.yellow, .systemYellow), (.green, .systemGreen), (.mint, .systemMint),
      (.teal, .systemTeal), (.cyan, .systemCyan), (.blue, .systemBlue),
      (.indigo, .systemIndigo), (.purple, .systemPurple), (.pink, .systemPink),
      (.brown, .systemBrown), (.gray, .systemGray),
    ]
#endif
