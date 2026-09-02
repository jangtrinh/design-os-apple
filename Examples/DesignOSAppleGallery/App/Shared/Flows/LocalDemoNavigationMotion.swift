import SwiftUI

private struct LocalDemoTransitionNamespaceKey: EnvironmentKey {
  static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
  var localDemoTransitionNamespace: Namespace.ID? {
    get { self[LocalDemoTransitionNamespaceKey.self] }
    set { self[LocalDemoTransitionNamespaceKey.self] = newValue }
  }
}

extension View {
  func localDemoTransitionSource(_ destination: LocalDemoDestination) -> some View {
    modifier(LocalDemoTransitionSourceModifier(id: destination.rawValue))
  }

  func localDemoDestinationTransition(_ destination: LocalDemoDestination) -> some View {
    modifier(LocalDemoDestinationTransitionModifier(id: destination.rawValue))
  }
}

private struct LocalDemoTransitionSourceModifier: ViewModifier {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.localDemoTransitionNamespace) private var namespace
  let id: String

  @ViewBuilder
  func body(content: Content) -> some View {
    #if os(iOS)
      if #available(iOS 18.0, *), let namespace, !reduceMotion {
        content.matchedTransitionSource(id: id, in: namespace)
      } else {
        content
      }
    #else
      content
    #endif
  }
}

private struct LocalDemoDestinationTransitionModifier: ViewModifier {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.localDemoTransitionNamespace) private var namespace
  let id: String

  @ViewBuilder
  func body(content: Content) -> some View {
    #if os(iOS)
      if #available(iOS 18.0, *), let namespace, !reduceMotion {
        content.navigationTransition(.zoom(sourceID: id, in: namespace))
      } else {
        content
      }
    #else
      content
    #endif
  }
}
