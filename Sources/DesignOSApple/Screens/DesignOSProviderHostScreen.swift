import SwiftUI

/// Native/provider-owned workflow with disclosure and persistent recovery content.
///
/// The provider slot owns its controls, scrolling, legal terms and lifecycle. The app obtains
/// required permissions and binds completion; this kit does not implement payment or identity.
public struct DesignOSProviderHostScreen<Provider: View, Disclosure: View, Recovery: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let provider: Provider
  private let disclosure: Disclosure
  private let recovery: Recovery

  public init(
    @ViewBuilder provider: () -> Provider,
    @ViewBuilder disclosure: () -> Disclosure,
    @ViewBuilder recovery: () -> Recovery
  ) {
    self.provider = provider()
    self.disclosure = disclosure()
    self.recovery = recovery()
  }

  public var body: some View {
    DesignOSNativeHostShell {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        disclosure
        provider.frame(maxWidth: .infinity, maxHeight: .infinity)
        recovery
      }
    }
  }
}
