import DesignOSApple
import SwiftUI
import Testing

#if os(iOS)
  import UIKit
#endif

@Test("Home Screen quick-action recipe exposes its platform-bounded native calls")
@MainActor
func homeScreenQuickActionRecipeContract() {
  _ = NativeHomeScreenQuickActionRecipe.self

  #if os(iOS)
    acceptsType(QuickActionSceneDelegateFixture.self)
    acceptsFunction(QuickActionFixture.install)
  #endif
}

private func acceptsType<Value>(_: Value.Type) {}
private func acceptsFunction<Value>(_: Value) {}

#if os(iOS)
  private enum QuickActionFixture {
    @MainActor
    static func install() {
      UIApplication.shared.shortcutItems = [makeItem()]
    }

    static func makeItem() -> UIApplicationShortcutItem {
      UIApplicationShortcutItem(
        type: "com.example.new-document",
        localizedTitle: "New Document",
        localizedSubtitle: "Create a document",
        icon: UIApplicationShortcutIcon(systemImageName: "doc.badge.plus")
      )
    }
  }

  @MainActor
  private final class QuickActionSceneDelegateFixture: NSObject, UIWindowSceneDelegate {
    func scene(
      _: UIScene,
      willConnectTo _: UISceneSession,
      options connectionOptions: UIScene.ConnectionOptions
    ) {
      _ = connectionOptions.shortcutItem
    }

    func windowScene(
      _: UIWindowScene,
      performActionFor _: UIApplicationShortcutItem,
      completionHandler: @escaping (Bool) -> Void
    ) {
      completionHandler(true)
    }
  }
#endif
