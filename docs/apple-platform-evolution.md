# Apple Platform Evolution

Apple Design OS keeps its semantic API stable while Apple changes platform appearance and
capabilities. Native SwiftUI controls remain direct calls so they inherit system behavior;
package-owned APIs describe intent instead of freezing annual visual details.

## Annual intake

1. Record each new or changed platform capability in `DesignOSRuntimeCatalog`, including
   platforms, minimum availability, fallback, state owner, accessibility owner,
   documentation, example, and verification command.
2. Add an executable typed Gallery story only when the capability has a real runtime or
   direct-native-API route. Unknown identities and unavailable routes fail closed.
3. Availability-gate new SDK calls and retain the oldest supported behavior. A beta SDK
   lane is discovery evidence; it cannot silently raise the package platform floor.
4. Deprecate semantic APIs before removal. Record migrations in `CHANGELOG.md`, preserve
   source compatibility within the supported release line, and use a major version for an
   intentional breaking contract.
5. Re-run deterministic gates on supported stable Xcode versions, then record device,
   VoiceOver, visual, and owner acceptance separately where required.

## Authority and decision rules

- Apple documentation, SDK availability, and observed platform behavior outrank Gallery
  appearance, Figma names, or historical screenshots.
- `DesignOSReleaseCatalog` is the compiled release inventory. Its generated bundle is a
  checked projection for people and agents, never an independent source of truth.
- `DesignOSPilotCatalog` remains a frozen five-story evidence boundary and does not grow with
  annual platform intake.
- New Apple-owned controls stay native. Add a package component only for reusable semantic
  composition that SwiftUI does not already own.

Support-floor changes, removed fallbacks, and adopted beta-only APIs require an explicit
maintainer decision before release.
