import Foundation
import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Editorial outgoing emphasis pairs readable text with directional blue in every appearance")
func outgoingMessageColorsMeetContrast() {
  let palette = DesignOSAppStyle.editorial.palette
  let pair = palette.outgoingMessage
  for dark in [false, true] {
    for increased in [false, true] {
      let background = pair.background.resolvedRGB(dark: dark, increasedContrast: increased)
      let foreground = pair.foreground.resolvedRGB(dark: dark, increasedContrast: increased)
      #expect(background == (increased ? 0x17_46B5 : 0x2A_62E8))
      #expect(foreground == 0xFF_FFFF)
      #expect(compositeContrast(foreground, background) >= (increased ? 7 : 4.5))
    }
  }
  // Conversation emphasis must not change the app's monochrome action hierarchy.
  #expect(palette.action.lightRGB == 0x16_1616)
  #expect(palette.action.darkRGB == 0xFF_FFFF)
  #expect(palette.actionInk.lightRGB == 0xFF_FFFF)
  #expect(palette.actionInk.darkRGB == 0x16_1616)
}

@Test("Existing custom palette initializers inherit their own surface and ink as one message pair")
func customMessagePaletteDefaultsStayPaired() throws {
  let base = DesignOSAppStyle.editorial.palette
  let surface = try DesignOSAdaptiveColor(
    lightRGB: 0xFF_F8E1, darkRGB: 0x10_2233,
    increasedContrastLightRGB: 0xFF_FFFF, increasedContrastDarkRGB: 0x00_0000
  )
  let ink = try DesignOSAdaptiveColor(
    lightRGB: 0x22_1100, darkRGB: 0xEE_FFFF,
    increasedContrastLightRGB: 0x00_0000, increasedContrastDarkRGB: 0xFF_FFFF
  )
  // Deliberately uses the original initializer, without a new argument.
  let palette = DesignOSAppPalette(
    canvas: base.canvas, surface: surface, subtleSurface: base.subtleSurface,
    ink: ink, secondaryInk: base.secondaryInk, separator: base.separator,
    action: base.action, actionInk: base.actionInk
  )
  #expect(palette.outgoingMessage == DesignOSAppColorPair(background: surface, foreground: ink))
  #expect(palette.outgoingMessage != base.outgoingMessage)
  for dark in [false, true] {
    for increased in [false, true] {
      #expect(
        compositeContrast(
          palette.outgoingMessage.foreground.resolvedRGB(dark: dark, increasedContrast: increased),
          palette.outgoingMessage.background.resolvedRGB(dark: dark, increasedContrast: increased)
        ) >= 4.5
      )
    }
  }
}

@Test("Explicit message color overrides replace the complete pair without changing other roles")
func customMessagePaletteAcceptsExplicitPair() throws {
  let base = DesignOSAppStyle.editorial.palette
  let pair = DesignOSAppColorPair(
    background: try DesignOSAdaptiveColor(lightRGB: 0x28_593D, darkRGB: 0xB9_F0CF),
    foreground: try DesignOSAdaptiveColor(lightRGB: 0xFF_FFFF, darkRGB: 0x10_2218)
  )
  let palette = DesignOSAppPalette(
    canvas: base.canvas, surface: base.surface, subtleSurface: base.subtleSurface,
    ink: base.ink, secondaryInk: base.secondaryInk, separator: base.separator,
    action: base.action, actionInk: base.actionInk, outgoingMessage: pair
  )
  #expect(palette.outgoingMessage == pair)
  #expect(palette.surface == base.surface)
  #expect(palette.ink == base.ink)
  #expect(palette.action == base.action)
  #expect(palette.actionInk == base.actionInk)
}

@Test("Intrinsic selection width follows content while respecting narrow host proposals")
func selectionSummaryIntrinsicWidthPolicy() {
  #expect(
    DesignOSSelectionSummarySizingPolicy.intrinsicWidth(idealWidth: 120, proposedWidth: 393) == 120)
  #expect(
    DesignOSSelectionSummarySizingPolicy.intrinsicWidth(idealWidth: 620, proposedWidth: 180) == 180)
  #expect(
    DesignOSSelectionSummarySizingPolicy.intrinsicWidth(idealWidth: 120, proposedWidth: nil) == 120)
  #expect(
    DesignOSSelectionSummarySizingPolicy.intrinsicWidth(idealWidth: 120, proposedWidth: 0) == 0)
  #expect(
    DesignOSSelectionSummarySizingPolicy.intrinsicWidth(idealWidth: 0, proposedWidth: 393) == 0)
  #expect(
    DesignOSSelectionSummarySizingPolicy.intrinsicWidth(idealWidth: 120, proposedWidth: -1) == 0)
  for unbounded in [CGFloat.infinity, .nan] {
    #expect(
      DesignOSSelectionSummarySizingPolicy.intrinsicWidth(
        idealWidth: 120, proposedWidth: unbounded) == 120)
  }
  for invalid in [CGFloat.infinity, .nan, -1] {
    #expect(
      DesignOSSelectionSummarySizingPolicy.intrinsicWidth(
        idealWidth: invalid, proposedWidth: 393) == 0)
  }
}

// Compilation fixtures exercise public opt-in and compatible default seams. They are not
// hosted measurements, button interaction, screenshot comparisons, or accessibility audits.
@Test("Message appearance options preserve caller-owned content and external native retry actions")
@MainActor
func messageBubbleAppearanceCompositionsCompile() {
  var retries = 0
  for outgoing in [false, true] {
    let bubble = DesignOSMessageBubble(isOutgoing: outgoing, outgoingAppearance: .emphasized) {
      Text("Reply context remains inside the content surface").font(.caption)
    } content: {
      Text("A longer outgoing message can wrap while its delivery information stays outside.")
    } metadata: {
      Text("Not delivered").font(.caption)
      Button("Retry") { retries += 1 }
    }
    acceptsCompositeAppearance(bubble.body)
    acceptsCompositeAppearance(bubble.environment(\.dynamicTypeSize, .accessibility5))
    acceptsCompositeAppearance(bubble.environment(\.layoutDirection, .rightToLeft))
    acceptsCompositeAppearance(bubble.environment(\.colorScheme, .dark))
    acceptsCompositeAppearance(
      DesignOSMessageBubble(isOutgoing: outgoing, outgoingAppearance: .emphasized) {
        Text("No reply context")
      } metadata: { Text("Delivered") }.body
    )
    acceptsCompositeAppearance(
      DesignOSMessageBubble(isOutgoing: outgoing) {
        Text("Existing neutral initializer")
      } metadata: { Text("Delivered") }.body
    )
  }
  #expect(retries == 0)
}

@Test("Intrinsic selection supports one native count action and localized accessible content")
@MainActor
func selectionSummarySizingCompositionsCompile() {
  var presentations = 0
  for label in ["2 Selected", "12 participants selected for the upcoming gathering"] {
    let compact = DesignOSSelectionSummary(sizing: .intrinsic) {
      Button {
        presentations += 1
      } label: {
        HStack {
          Text(label)
          Image(systemName: "chevron.right").accessibilityHidden(true)
        }
      }
      .buttonStyle(DesignOSSecondaryButtonStyle())
    } actions: {
      EmptyView()
    }
    acceptsCompositeAppearance(compact.body)
    acceptsCompositeAppearance(compact.frame(width: 180))
    acceptsCompositeAppearance(compact.environment(\.dynamicTypeSize, .accessibility5))
    acceptsCompositeAppearance(compact.environment(\.layoutDirection, .rightToLeft))
  }
  acceptsCompositeAppearance(
    DesignOSSelectionSummary {
      Text("2 Selected")
    } actions: {
      Button("Continue") { presentations += 1 }
    }.body
  )
  acceptsCompositeAppearance(
    DesignOSSelectionSummary(sizing: .intrinsic) {
      EmptyView()
    } actions: {
      Button("Review selection") { presentations += 1 }
    }.body
  )
  acceptsCompositeAppearance(
    DesignOSSelectionSummary(sizing: .intrinsic) {
      EmptyView()
    } actions: { EmptyView() }.body
  )
  #expect(presentations == 0)
}

private func acceptsCompositeAppearance(_: some View) {}

private func compositeContrast(_ first: UInt32, _ second: UInt32) -> Double {
  func luminance(_ rgb: UInt32) -> Double {
    let channels = [16, 8, 0].map { shift -> Double in
      let value = Double((rgb >> shift) & 0xFF) / 255
      return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
    return channels[0] * 0.2126 + channels[1] * 0.7152 + channels[2] * 0.0722
  }
  let values = [luminance(first), luminance(second)]
  return (values.max()! + 0.05) / (values.min()! + 0.05)
}
