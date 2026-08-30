import DesignOSApple
import Testing

@Test("Surface roles are unique construction intent")
func surfaceRolesAreUnique() {
  let roles: [DesignOSSurfaceRole] = [.content, .groupedContent, .translucentContent]

  #expect(roles.count == 3)
  #expect(Set(roles).count == roles.count)
}

@Test("Surface roles meet immutable public compile contracts")
func surfaceRolesMeetPublicCompileContracts() {
  requireHashableAndSendable(DesignOSSurfaceRole.self)
  acceptsPublicSurfaceRole(.content)
}

private func requireHashableAndSendable<Value: Hashable & Sendable>(_: Value.Type) {}

private func acceptsPublicSurfaceRole(_: DesignOSSurfaceRole) {}
