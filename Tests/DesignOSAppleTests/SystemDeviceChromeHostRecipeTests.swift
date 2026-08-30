import DesignOSApple
import LocalAuthentication
import SwiftUI
import Testing
import UserNotifications

#if os(iOS)
  import UIKit
#endif

@Test("System-host recipe exposes native scene, safe-area, symbol, and service calls")
@MainActor
func systemDeviceChromeHostRecipeContract() {
  _ = SystemDeviceChromeHostRecipe.self
  acceptsApp(SystemHostAppFixture())
  acceptsFunction(SystemServiceFixture.makeAuthenticationContext)
  acceptsFunction(SystemServiceFixture.currentNotificationCenter)

  #if os(iOS)
    acceptsFunction(IOSSystemHostFixture.makeQuickAction)
  #endif
}

private func acceptsApp(_: some App) {}
private func acceptsFunction<Value>(_: Value) {}

private struct SystemHostAppFixture: App {
  var body: some Scene {
    WindowGroup {
      SystemHostContentFixture()
    }
  }
}

private struct SystemHostContentFixture: View {
  @State private var text = ""

  var body: some View {
    VStack {
      Image(systemName: "lock.shield")
        .accessibilityLabel("Security")

      #if os(iOS)
        TextField("Message", text: $text)
          .textInputAutocapitalization(.sentences)
          .keyboardType(.default)
      #else
        TextField("Message", text: $text)
      #endif
    }
    .safeAreaInset(edge: .bottom) {
      Text("App-owned actions")
    }
  }
}

private enum SystemServiceFixture {
  static func makeAuthenticationContext() -> LAContext {
    LAContext()
  }

  static func currentNotificationCenter() -> UNUserNotificationCenter {
    .current()
  }
}

#if os(iOS)
  private enum IOSSystemHostFixture {
    static func makeQuickAction() -> UIApplicationShortcutItem {
      UIApplicationShortcutItem(
        type: "com.example.open",
        localizedTitle: "Open",
        localizedSubtitle: nil,
        icon: UIApplicationShortcutIcon(systemImageName: "arrow.up.right.square")
      )
    }
  }
#endif
