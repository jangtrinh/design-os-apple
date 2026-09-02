# Reference Reconstruction Workflow

Use this workflow when adding a local-only Gallery mini app from visual research. The
reference is evidence for composition and interaction analysis; its pixels, protected
branding, copy, and media do not ship in the implementation.

## 1. Lock the evidence

- Record stable flow and screen identities, local filenames, and SHA-256 hashes.
- Define whether each capture is a route, transient presentation, or scroll position.
- Preserve the original state relationship. Two screenshots of one scrolled page are not
  two navigation destinations.
- Declare the viewport before implementation. A folder name is not viewport proof.

## 2. Model the native boundary

Classify every visible element before coding:

- **Native owner:** navigation, controls, text input, menus, sharing, maps, scrolling, and
  platform services stay direct SwiftUI or Apple framework calls.
- **Reusable primitive:** semantic color, typography, spacing, radius, surface, artwork,
  and layout helpers may be composed locally.
- **Semantic component:** app-shaped cards, composers, rows, and sheets combine primitives
  but do not replace native behavior.
- **Reference-only detail:** protected identity or incidental content is replaced with
  original generic fixtures.

Every element that looks interactive must change rendered state, navigate, invoke a
native service, or be visually demoted to noninteractive content.

### Classify appearance ownership

Decide appearance at the destination boundary before assigning literal colors:

- **Adaptive destination:** canvas, surface, field, sheet, card, primary ink, and secondary
  ink each own paired light and dark values. Brand accents may remain stable when contrast
  holds. Do not force a color scheme inside a reusable subview.
- **Authored destination:** media-led experiences may stay intentionally dark only when the
  whole destination owns the treatment, including native navigation chrome and safe-area
  canvas.
- **Fixed contrast role:** literal white or black is reserved for foregrounds over accents or
  media, scrims, shadows, strokes, and authored artwork. It is not a generic card or page
  surface.

Capture every admitted state in both system appearances. Adaptive destinations must visibly
adapt without mixed-scheme islands; authored destinations must remain coherent in both host
appearances.

## 3. Build measurable contracts

The current Gallery baseline is:

| Contract | Baseline |
|---|---|
| Page and sheet horizontal gutter | 16 points |
| Smallest text role | `caption` / 12-point semantic floor |
| Independent hit target | 44 by 44 points |
| Typography | Semantic Dynamic Type roles; no fixed UI font sizes |
| Back navigation | Outer native navigation owner |
| Reduce Motion | No layout animation; opacity-only disclosure fallback is allowed |
| Reduce Transparency | Opaque surface fallback |
| Catalog | Two columns outside accessibility Dynamic Type sizes |

Keep state and motion in the same feature boundary. A control is not complete when only
its tint changes while represented content stays unchanged.

## 4. Verify in layers

Run the narrow static and renderer checks before simulator capture:

```bash
scripts/verify-local-demo-design-gate.sh
node scripts/verify-local-demo-catalog.mjs --root .
node scripts/verify-local-demo-image-provenance.mjs --root .
```

Then run the source-bound UI capture and the cross-platform Gallery gate:

```bash
scripts/verify-gallery.sh
swift test
swift build -c release -Xswiftc -strict-concurrency=complete -Xswiftc -warnings-as-errors
```

For local demos, retain a 24-frame appearance matrix: 12 admitted states in light and the
same 12 in dark. Treat interaction PASS and visual disposition as separate evidence.

Capture receipts must retain device identity, point viewport, raw pixel dimensions, test
result, attachment count, selected source paths, and a reproducible aggregate source hash.
Recapture after the final selected-source edit.

## 5. Review without collapsing gates

Keep these dispositions separate:

- deterministic build and exercised behavior;
- independent visual review;
- runtime accessibility and physical-device qualification;
- owner acceptance and any numeric fidelity target.

A simulator test PASS cannot promote an unreviewed visual, VoiceOver, or owner gate.
Likewise, a visual PASS cannot prove every interaction path. The HTML comparison must say
which evidence revision it renders and must not invent numeric scores.

## AI-facing contract

AI agents should read the typed local-demo manifest, source paths, and evidence receipt
instead of inferring availability from screenshots or display names. Generated images are
Gallery-only fixtures with explicit clean-room provenance; they are not public package
resources or Apple assets.

When Apple changes a native API, update the platform evolution ledger first, then rerun
the same reconstruction and evidence layers. Prefer replacing custom compatibility code
with the newer native API when deployment targets permit it.
