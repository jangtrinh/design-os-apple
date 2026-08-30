# Color roles

Use ``DesignOSColorRole`` to express semantic intent while UIKit or AppKit resolves the current appearance.

```swift
Text("Account")
  .foregroundStyle(DesignOSColorRole.labelPrimary.color)
```

Do not cache the resolved color or replace it with a Figma light-mode literal. The native color remains responsible for dark appearance and increased contrast.

``DesignOSSemanticColorProfile`` can select the supporting-text role consumed by
package-owned row content. It still stores a ``DesignOSColorRole`` rather than resolved RGB,
so UIKit or AppKit remains responsible for the active appearance.
