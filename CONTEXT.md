# Apple Design OS

Native design-system foundation shared by iOS, iPadOS, and macOS products.

## Language

**Design system**:
The complete managed system of design intent, semantic tokens, component contracts, native implementations, and evidence.
_Avoid_: UI kit, style collection

**Management source of truth**:
The DESIGN:OS state in `design/`, including tokens, component registry, manifest, and provenance.
_Avoid_: token dump, config folder

**Runtime implementation**:
The SwiftUI library that delivers managed design decisions to Apple-platform applications.
_Avoid_: generated UI, app shell

**Platform-adaptive component**:
A component with one semantic contract whose interaction and presentation respect each Apple platform.
_Avoid_: identical cross-platform component, universal widget
