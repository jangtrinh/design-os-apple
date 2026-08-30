# ``DesignOSListRow``

Compose reusable row content inside a native `List`, `Section`, `Button`, or `NavigationLink`.

```swift
List {
  NavigationLink(value: Route.document) {
    DesignOSListRow {
      Image(systemName: "doc")
    } title: {
      Text("Document")
    } subtitle: {
      Text("Updated today")
    } trailing: {
      Text("12 KB")
    }
  }
}
```

The component owns content order only. The native host owns row metrics, selection, actions, focus, gestures, disabled state, and accessibility traits.
