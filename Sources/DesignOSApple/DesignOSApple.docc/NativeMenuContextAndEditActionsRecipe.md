# ``NativeMenuContextAndEditActionsRecipe``

Call `Menu`, `.contextMenu`, and `.swipeActions` directly. Use native `Button` roles so the system owns menu chrome, gesture behavior, focus, pointer behavior, and destructive semantics.

```swift
Menu("Actions", systemImage: "ellipsis.circle") {
  Button("Delete", systemImage: "trash", role: .destructive) { delete() }
}
```
