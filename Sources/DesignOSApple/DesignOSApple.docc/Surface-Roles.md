# Surface roles

``DesignOSSurfaceRole`` records construction intent for custom non-interactive content surfaces.

Use native `List`, `Form`, navigation, sheet, popover, and window backgrounds whenever those containers already own the surface. A custom translucent surface must provide an opaque reduced-transparency fallback.

``DesignOSSurfaceProfile`` selects construction intent only for package-owned custom
content. ``DesignOSAccessibilityPolicy`` is applied after the system preference: it may
force optional translucency opaque, but never overrides reduced transparency. Radius and
surface groups do not theme native controls or system containers.

Apply the profile to custom non-interactive content explicitly:

```swift
SummaryCard()
  .designOSCustomSurface()
```

Do not apply this modifier to `List`, `Form`, controls, navigation, sheets, popovers, or
windows; those native containers already own their surface and interaction behavior.
