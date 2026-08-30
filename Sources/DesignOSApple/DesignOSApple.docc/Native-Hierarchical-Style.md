# Native hierarchical style

Use ``NativeHierarchicalStyleRecipe`` to document direct SwiftUI hierarchical foreground styles.

```swift
VStack(alignment: .leading) {
  Text("Primary")
  Text("Supporting detail").foregroundStyle(.secondary)
}
```

Hierarchy is visual emphasis, not an accessibility name or state. Never encode meaning through color alone.
