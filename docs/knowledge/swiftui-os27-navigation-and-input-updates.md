---
id: swiftui-os27-navigation-and-input-updates
title: "SwiftUI OS27 Navigation TabsPickerStyle and Border Shapes"
domain: "ui-ux"
description: "SwiftUI updates in OS 27 including TabsPickerStyle, text input border shapes, concentric corner radii, and menu subtitles."
when: ["swiftui-os27", "TabsPickerStyle", "textInputBorderShape", "concentricCornerRadii", "menu-subtitle"]
trust_tier: "verified"
version: "1.0.0"
source_attribution:
  uri: "https://developer.apple.com/tutorials/data/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes.json"
  modality: "web"
  sha256: "da7aaaa3899ee160e0a93a0d22b6b87b32b676121c341588fcc7415e32b9e834"
  captured_at: "2026-10-01T08:24:26Z"
  license: "Apple Inc. Copyright — source-reference-only; no MIT relicensing."
quarantine:
  is_external_untrusted: false
relationships:
  linked_units:
    - id: "ios27-adaptive-multitasking-and-splitview"
      relationship: "complements"
    - id: "macos27-appkit-menu-and-navigation-evolution"
      relationship: "complements"
---

# SwiftUI OS27 Navigation TabsPickerStyle and Border Shapes

## Purpose
Summarizes verified SwiftUI framework additions introduced across the OS 27 release cycle (iOS 27, iPadOS 27, macOS 27), including navigation picker styles, input border shapes, concentric corner radii, and menu subtitle mappings.

## When to Use / When NOT
### ALLOWED (When to Use)
- When evaluating future API migrations from `.squareBorder` / `.roundedBorder` toward `.bordered` and `textInputBorderShape`.
- When understanding how `TabsPickerStyle` bridges segmented picker UI to VoiceOver tab semantics.
- When planning container geometry matching using `concentricCornerRadii` on `GeometryProxy`.

### NOT ALLOWED (When NOT to Use)
- Do NOT directly use `TabsPickerStyle` or `textInputBorderShape` in the current package codebase targeting Xcode 26.2 (symbols do not exist in iOS 17–26 SDKs).
- Do NOT hardcode concentric corner radii calculations when standard system corner radiuses satisfy design tokens.
- Do NOT break backward compatibility with iOS 17 or macOS 14 package baselines.

## Core Knowledge Content
<!-- ease:source ref="https://developer.apple.com/tutorials/data/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes.json" sha256="da7aaaa3899ee160e0a93a0d22b6b87b32b676121c341588fcc7415e32b9e834" captured="2026-10-01T08:24:26Z" -->
The OS 27 SDK introduces notable declarative SwiftUI enhancements:
1. **TabsPickerStyle**:
   - Introduces `TabsPickerStyle` for pickers that represent tab-based navigation and content selection. Similar to `.segmented`, but announced to VoiceOver as "tabs" with distinct visual rendering on macOS, distinguishing navigational tabs from value-selection pickers. `(173211711)`
2. **Text Input Border Shapes**:
   - Adds `TextInputBorderShape` and the `textInputBorderShape(_:)` modifier for custom input borders. Soft-deprecates `.squareBorder` and `.roundedBorder` styles in favor of `.bordered`. `(173362083)`
3. **Concentric Corner Radii on GeometryProxy**:
   - `GeometryProxy` exposes `concentricCornerRadii` and `concentricCornerRadii(in:)`, returning optional `RectangleCornerRadii` concentric with the outer container shape. `(177185166)`
4. **Menu LabeledContent Subtitle Mapping**:
   - In apps built with the 27.0 SDKs, `LabeledContent` inside a SwiftUI `Menu` automatically maps its secondary value to the platform menu item's subtitle. `(175594929)`
5. **Toolbar Minimization**:
   - Replaces `toolbarMinimizeBehavior` with `toolbarMinimizationBehavior`. `(177954148)`

## Failure Modes (Mandatory)
1. **UnconditionalAdoption**: Immediate compilation failure on current stable Xcode 26.2 when referencing OS 27 symbols like `TabsPickerStyle` without availability gates. `(173211711)`
2. **ConcentricRadiiMiscalculation**: Potential visual misalignment when computing manual radii offsets instead of reading `concentricCornerRadii` from container proxies. `(177185166)`
3. **MenuSecondaryContentShift**: Potential layout differences when expecting secondary text in `LabeledContent` inside a menu to render inline rather than mapping to a subtitle in 27.0 SDKs. `(175594929)`
