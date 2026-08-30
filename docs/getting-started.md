# Getting Started

Add the local `DesignOSApple` package product to an iOS, iPadOS, or macOS app target. The
runtime composes content inside native SwiftUI containers; it does not replace `List`,
navigation, selection, or button behavior.

<!-- verify-swift-start -->
```swift
import DesignOSApple
import SwiftUI

struct AccountList: View {
  var body: some View {
    List {
      DesignOSListRow {
        Label("Profile", systemImage: "person.crop.circle")
      } title: {
        Text("Account")
      } subtitle: {
        Text("Manage identity and sign-in")
      } trailing: {
        Image(systemName: "chevron.forward")
          .foregroundStyle(.secondary)
      }
    }
    .designOSProfile(.default)
  }
}
```
<!-- verify-swift-end -->

Keep interaction with the caller. Put the row inside a `NavigationLink` when it navigates,
or inside a `Button` when it performs an action. Do not add an interaction wrapper merely
to match the Gallery.

## Customize consumed design language

Create a validated `DesignOSProfile` when the product needs a different font design,
content spacing, custom-content corner radius, or semantic surface. Inject it at one
subtree boundary with `.designOSProfile(_:)`. Native control geometry, navigation,
presentation, focus, and system chrome remain owned by SwiftUI.

The detailed contract lives in
[Profiles and Dogfood Catalog](../Sources/DesignOSApple/DesignOSApple.docc/Profiles-and-Dogfood-Catalog.md).
