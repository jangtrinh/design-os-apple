---
id: macos27-appkit-menu-and-navigation-evolution
title: "macOS 27 AppKit Menu Visibility and Navigation Evolution"
domain: "architecture"
description: "AppKit menu item image hiding, NSMenuItem.preferredImageVisibility, NSSegmentedControl tabs role, and NSRefreshController on macOS 27."
when: ["macos27", "appkit", "menu-visibility", "preferredImageVisibility", "tabs-role", "nsrefreshcontroller"]
trust_tier: "verified"
version: "1.0.0"
source_attribution:
  uri: "https://developer.apple.com/tutorials/data/documentation/macos-release-notes/macos-27-release-notes.json"
  modality: "web"
  sha256: "5c77ef7cc0c4e59d8a7fa6a3132729ec6c58492f11f49f168006a72a25bc6fdd"
  captured_at: "2026-10-01T08:24:26Z"
  license: "Apple Inc. Copyright — source-reference-only; no MIT relicensing."
quarantine:
  is_external_untrusted: false
relationships:
  linked_units:
    - id: "swiftui-os27-navigation-and-input-updates"
      relationship: "complements"
---

# macOS 27 AppKit Menu Visibility and Navigation Evolution

## Purpose
Documents primary architectural changes in macOS 27 AppKit, including default menu item image hiding, explicit `preferredImageVisibility` controls, semantic tab roles for segmented controls, and native scroll pull-to-refresh.

## When to Use / When NOT
### ALLOWED (When to Use)
- When auditing macOS menus and context actions against macOS 27 visual guidelines.
- When configuring toolbar item groups or segmented controls to adopt the semantic tabs role for proper VoiceOver and visual hierarchy.
- When planning future AppKit adoption of `NSRefreshController` on `NSScrollView`.

### NOT ALLOWED (When NOT to Use)
- Do NOT directly call `NSMenuItem.preferredImageVisibility` in source code targeting toolchains earlier than Xcode 27 / macOS 27 without availability checks.
- Do NOT assume menu item symbol images will automatically render on macOS 27 without explicit configuration.
- Do NOT remove system standard menu item images for Settings, Share, and Print, which the system continues to supply automatically.

## Core Knowledge Content
<!-- ease:source ref="https://developer.apple.com/tutorials/data/documentation/macos-release-notes/macos-27-release-notes.json" sha256="5c77ef7cc0c4e59d8a7fa6a3132729ec6c58492f11f49f168006a72a25bc6fdd" captured="2026-10-01T08:24:26Z" -->
The macOS 27 release notes specify important AppKit framework evolutions:
1. **Menu Item Image Visibility Policy (AppKit)**:
   - In macOS 27.0, menu bar and context menus present a reduced set of menu item images.
   - By default, `NSMenu` hides all menu item symbol images — non-symbol images remain visible. For menu items created from a xib file, `NSMenu` observes the value of the "macOS 26.0 only" checkbox in the menu item inspector. These changes apply to applications linked on macOS 26.0 and later. `(170477566)`
   - The new `preferredImageVisibility` property on `NSMenuItem` allows applications to customize menu item image visibility where needed.
   - System-wide menu items (such as Settings, Share, and Print) retain automatic system-provided visible images.
2. **Menu Element Image Visibility (UIKit on iPadOS & macOS Catalyst)**:
   <!-- ease:source ref="https://developer.apple.com/tutorials/data/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes.json" sha256="da7aaaa3899ee160e0a93a0d22b6b87b32b676121c341588fcc7415e32b9e834" captured="2026-10-01T08:24:26Z" -->
   - On iPadOS 27.0 and macOS 27.0, UIKit menu bar and context menus do not display images set on menu elements by default.
   - The new `preferredImageVisibility` property on `UIMenuElement` (with updated initializers on `UIMenu`, `UIAction`, `UICommand`, `UIKeyCommand`) controls element image visibility. `(170479084)`
3. **Semantic Tabs Role for Segmented Controls & Toolbars**:
   - `NSSegmentedControl` adds a `role` property and `NSSegmentedControlRole` enum, including a `.tabs` role for controls representing tab-based navigation and content selection. Controls are read by VoiceOver as "tabs" and display a distinct visual appearance that clearly distinguishes navigation from value selection. `(162577742)`
   - `NSToolbarItemGroup` adds a `role` property and `NSToolbarItemGroupRole` enum.
4. **Native Pull-To-Refresh**:
   - AppKit introduces `NSRefreshController`, providing native pull-to-refresh functionality for `NSScrollView`. `(160867808)`
5. **Window Chrome Overhang**:
   - For apps linked on macOS 27.0 or later, `NSTitlebarAccessoryViewController` is permitted to draw outside its bounds by default, supporting effects such as shadows and interactive glass effects. `(180962967)`

## Failure Modes (Mandatory)
1. **AssumingMenuIconsAlwaysVisible**: Potential loss of visual affordance when relying on menu icons to convey critical meaning without text labels on macOS 27. `(170477566)`
2. **ConflatingTabNavigationWithValueSelection**: Potential VoiceOver accessibility ambiguity when using segmented controls for tab navigation without the semantic tabs role. `(162577742)`
3. **PrematureSymbolInvocation**: Immediate compile error when calling `preferredImageVisibility` or `NSRefreshController` on Xcode 26.2 without compiler availability gates.
