import Testing

@testable import DesignOSApple

@Test("The design-system module is available")
func moduleIsAvailable() {
  _ = DesignOSApple.self
}
