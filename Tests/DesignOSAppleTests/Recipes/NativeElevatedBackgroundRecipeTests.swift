import DesignOSApple
import SwiftUI
import Testing

@Test("Elevated background recipe is a public metadata namespace")
func elevatedBackgroundRecipeContract() {
  _ = NativeElevatedBackgroundRecipe.self
  acceptsView(ElevatedBackgroundFixture())
}

private func acceptsView(_: some View) {}

private struct ElevatedBackgroundFixture: View {
  var body: some View {
    VStack {
      Text("Primary").background(DesignOSColorRole.backgroundPrimary.color)
      Text("Secondary").background(DesignOSColorRole.backgroundSecondary.color)
      Text("Tertiary").background(DesignOSColorRole.backgroundTertiary.color)
      Text("Grouped primary").background(DesignOSColorRole.groupedBackgroundPrimary.color)
      Text("Grouped secondary").background(DesignOSColorRole.groupedBackgroundSecondary.color)
      Text("Grouped tertiary").background(DesignOSColorRole.groupedBackgroundTertiary.color)
    }
  }
}
