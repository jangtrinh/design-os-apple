# ``NativeContentUnavailableViewRecipe``

Call `ContentUnavailableView` directly on iOS, iPadOS, and macOS. Supply product-specific labels and actions; keep layout and accessibility semantics native.

```swift
ContentUnavailableView(
  "No results",
  systemImage: "magnifyingglass",
  description: Text("Try a different search.")
)
```
