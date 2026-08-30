# ``NativeButtonAndToolbarActionRecipe``

Call `Button` and `ToolbarItem` directly. The caller owns actions and disabled state; SwiftUI owns activation, focus, placement, and chrome.

```swift
Button("Save", systemImage: "checkmark") { save() }
  .disabled(!canSave)
```
