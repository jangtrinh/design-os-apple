# ``DesignOSSidebarRow``

Compose label and accessory content inside a native selection-aware sidebar list.

```swift
List(selection: $selection) {
  NavigationLink(value: Route.downloads) {
    DesignOSSidebarRow {
      Label("Downloads", systemImage: "arrow.down.circle")
    } accessory: {
      Text("4")
    }
  }
}
```

`NavigationSplitView`, `List(selection:)`, and `DisclosureGroup` keep ownership of routing, selection, indentation, focus, and expanded-state announcements.
