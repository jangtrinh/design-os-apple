export const CATALOG_THUMBNAIL_STYLE = `
Use case: ui-mockup
Asset type: Apple Design OS catalog thumbnail
Primary request: Generate one original thumbnail representing {{SUBJECT}} in a native SwiftUI design system.
Input images: any supplied images are style references only; do not copy their subjects.
Scene/backdrop: pure white drafting-paper field with a barely visible pale gray isometric construction grid and generous clean margins.
Subject: {{COMPOSITION}}
Style/medium: precise black and graphite technical line illustration translated to UI; thin uniform hairlines, restrained pale-gray fills, one tiny Apple-blue accent only; crisp, quiet, editorial, highly legible at thumbnail size.
Composition/framing: landscape 4:3, centered within a shallow rectangular drafting slab, subject occupies about 58% of canvas, generous negative space.
Lighting/mood: flat neutral paper, almost no shadow.
Constraints: no mechanical objects; no exploded parts; no 3D machinery; no perspective distortion of the UI; no photorealism; no people; no device bezel; no readable text; no logos; no watermark; no brand names; no gradients; no dark background. Every visible control must look intentional and aligned.
Avoid: generic dashboard screenshots, neon colors, heavy shadows, glassmorphism, floating cards, tiny illegible labels.
`.trim()

export const CATALOG_THUMBNAIL_SLOTS = Object.freeze({
  "foundation.profile-customization": {
    subject: "profile customization",
    composition:
      "a simple flat settings specimen made from three nested rounded UI panels: one typography sample line, one horizontal spacing ruler, four corner-radius samples, and a small semantic color-swatch row",
  },
  "foundation.color-roles": {
    subject: "semantic color roles",
    composition:
      "a compact semantic color board with aligned swatch rows for label, fill, background, separator, accent, success, warning, and destructive roles",
  },
  "foundation.platform-semantic-color": {
    subject: "platform-adaptive semantic color",
    composition:
      "three aligned native UI panels for phone, tablet, and desktop showing the same semantic roles adapting between light and dark surfaces",
  },
  "foundation.typography": {
    subject: "Apple platform typography roles",
    composition:
      "a disciplined type-scale specimen with large title, headline, body, callout, caption, baseline guides, and Dynamic Type size markers",
  },
  "foundation.surface-roles": {
    subject: "semantic surface roles",
    composition:
      "a nested stack of background, grouped background, elevated card, popover, and separator surfaces with restrained depth cues",
  },
  "component.list-row": {
    subject: "a reusable native list row",
    composition:
      "one polished list row anatomy with leading symbol, title and subtitle lines, trailing value, disclosure indicator, alignment guides, and touch-target bounds",
  },
  "component.sidebar-row": {
    subject: "a selected native sidebar row",
    composition:
      "a compact sidebar column with three rows, one selected row, aligned symbols, labels, badge, and selection background",
  },
  "primitive.accessory-slot-layout": {
    subject: "accessory slot layout",
    composition:
      "a row anatomy diagram split into leading, content, secondary, trailing, and accessory slots with alignment and spacing guides",
  },
  "primitive.section-content-layout": {
    subject: "section content layout",
    composition:
      "a native section with header, optional trailing action, two content rows, footer, and clear inset guides",
  },
  "primitive.sidebar-toolbar-content": {
    subject: "sidebar toolbar content",
    composition:
      "a narrow sidebar with grouped rows and a bottom toolbar containing add, settings, and overflow actions",
  },
  "primitive.symbol-content": {
    subject: "symbol content treatments",
    composition:
      "a three-column symbol specimen showing plain, circular, and rounded-square containers with consistent optical sizing",
  },
  "native.button-toolbar-actions": {
    subject: "native button and toolbar action roles",
    composition:
      "a native top toolbar above bordered, prominent, destructive, and icon-only buttons with hierarchy and spacing guides",
  },
  "native.content-unavailable": {
    subject: "a native content-unavailable state",
    composition:
      "a centered empty-state arrangement with a simple symbol, two text bars, one primary action, and a surrounding content frame",
  },
  "native.elevated-background": {
    subject: "native elevated backgrounds",
    composition:
      "two overlapping content cards above a grouped surface, using subtle elevation, separators, and platform-correct rounded corners",
  },
  "native.hierarchical-style": {
    subject: "hierarchical foreground styles",
    composition:
      "four aligned text-and-symbol rows progressing from primary to quaternary emphasis on one semantic surface",
  },
  "native.home-screen-quick-actions": {
    subject: "home-screen quick actions",
    composition:
      "a simple app tile beside a compact native quick-action menu with four icon rows and one destructive action",
  },
  "native.list-sidebar-disclosure": {
    subject: "list, sidebar, and disclosure navigation",
    composition:
      "a compact split-view composition with selected sidebar row, content list, disclosure chevrons, and one visible detail pane",
  },
  "native.material-glass-surface": {
    subject: "native material and glass surfaces",
    composition:
      "two restrained translucent interface panels over a faint neutral content field, with crisp separators and no decorative gradients",
  },
  "native.menu-context-edit-actions": {
    subject: "menus, context actions, and edit actions",
    composition:
      "one list row exposing a compact swipe-action rail beside a native context menu with grouped actions",
  },
  "native.navigation-tabs-toolbars": {
    subject: "navigation, tabs, and toolbars",
    composition:
      "a native content frame with top navigation toolbar, central content region, and four-item bottom tab bar with one selected tab",
  },
  "native.picker-date-color-input": {
    subject: "native picker, date, and color input controls",
    composition:
      "three aligned control specimens: segmented picker, compact date field, and circular color well with labels represented as bars",
  },
  "native.presentation-share": {
    subject: "native presentation and sharing",
    composition:
      "a content card presenting a bottom sheet, with a compact share panel of destinations and action rows beside it",
  },
  "native.progress-slider-stepper": {
    subject: "progress, slider, and stepper controls",
    composition:
      "three aligned control tracks showing determinate progress, an adjustable slider, and a minus-value-plus stepper",
  },
  "native.text-search-keyboard-input": {
    subject: "text, search, and keyboard input",
    composition:
      "a focused native search field above three result rows, plus a small keyboard-focus indicator and clear action",
  },
  "native.system-device-chrome-host": {
    subject: "system and device chrome ownership",
    composition:
      "three abstract platform content frames showing safe areas, top toolbar ownership, bottom system region, and desktop window toolbar boundaries",
  },
  "extension.widget": {
    subject: "Apple platform widgets",
    composition:
      "small, medium, and large widget tiles arranged on a clean grid with simple native data hierarchy and container margins",
  },
  "extension.control-widget": {
    subject: "control widgets",
    composition:
      "four compact control-widget tiles for toggle, action, status, and adjustable value, each with one clear symbol and state",
  },
  "omniact.settings-shell": {
    subject: "a native desktop settings shell",
    composition:
      "a macOS-style settings window with compact sidebar, selected category, two form groups, native toggles, and one footer action",
  },
  "omniact.command-row": {
    subject: "a reusable command row",
    composition:
      "a polished command-palette row with leading symbol, command label bars, optional description, keyboard shortcut, and selection state",
  },
  "tocchien.dictionary-search": {
    subject: "a mobile dictionary search flow",
    composition:
      "a native search field above three concise dictionary result rows, with one expanded definition card and favorite action",
  },
  "tocchien.navigation-tabs": {
    subject: "mobile app navigation tabs",
    composition:
      "a native mobile content frame with simple navigation title, stacked content cards, and a four-item bottom tab bar with one selected tab",
  },
  "tocchien.champion-hero-negative-control": {
    subject: "an app-specific hero card and design-system ownership boundary",
    composition:
      "one expressive app hero card beside a restrained design-system boundary diagram, clearly separating product artwork from reusable native controls",
  },
})

export function assetName(storyID) {
  return `catalog-${storyID.replaceAll(".", "-")}`
}

export function buildPrompt(storyID) {
  const slot = CATALOG_THUMBNAIL_SLOTS[storyID]
  if (!slot) throw new Error(`Unknown catalog thumbnail story ID: ${storyID}`)
  return CATALOG_THUMBNAIL_STYLE.replace("{{SUBJECT}}", slot.subject).replace(
    "{{COMPOSITION}}",
    slot.composition,
  )
}
