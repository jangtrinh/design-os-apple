/// Metadata anchor for iOS and iPadOS Home Screen quick-action integration.
///
/// App hosts create `UIApplicationShortcutItem` values, set `UIApplication.shortcutItems`,
/// route initial connection options, and handle actions with the `UIWindowSceneDelegate`
/// callback. The app owns routing and completion; the Home Screen owns presentation and
/// interaction. Localized titles must name actions independently of icons. UIKit calls
/// stay behind an iOS platform boundary; there is no macOS or extension implementation.
public enum NativeHomeScreenQuickActionRecipe {}
