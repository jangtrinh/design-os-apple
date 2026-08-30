# ``NativeListSidebarAndDisclosureRecipe``

Compose `List`, `Section`, `NavigationSplitView`, and `DisclosureGroup` directly. Keep data and bindings in the app; preserve native scrolling, row metrics, selection, focus, and disclosure announcements.

```swift
List(selection: $selection) {
  Section("Library") {
    NavigationLink(value: Route.recent) { Label("Recent", systemImage: "clock") }
  }
}
```
