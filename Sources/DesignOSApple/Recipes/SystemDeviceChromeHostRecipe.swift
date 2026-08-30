/// Metadata anchor for system-owned scene, service, and device-chrome host integration.
///
/// App targets use `App`, `Scene`, `WindowGroup`, `safeAreaInset`, system symbols,
/// `LAContext`, and `UNUserNotificationCenter` at their native host boundaries. UIKit
/// text-input traits and `UIApplicationShortcutItem` stay iOS-only. The system owns status
/// and menu bars, keyboards, prompts, notifications, lock and Home screens, the dock,
/// window controls, and their accessibility semantics; app content supplies its own
/// labels, Dynamic Type behavior, and app-owned safe-area content.
public enum SystemDeviceChromeHostRecipe {}
