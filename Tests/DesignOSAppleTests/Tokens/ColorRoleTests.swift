import DesignOSApple
import Testing

@Test("Color roles are unique semantic values")
func colorRolesAreUnique() {
  let roles: [DesignOSColorRole] = [
    .labelPrimary, .labelSecondary, .labelTertiary, .labelQuaternary,
    .backgroundPrimary, .backgroundSecondary, .backgroundTertiary,
    .groupedBackgroundPrimary, .groupedBackgroundSecondary, .groupedBackgroundTertiary,
    .fillPrimary, .fillSecondary, .fillTertiary, .fillQuaternary,
    .separator,
    .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple,
    .pink, .brown, .gray,
  ]

  #expect(roles.count == 28)
  #expect(Set(roles).count == roles.count)
}

@Test("Color roles meet immutable public compile contracts")
func colorRolesMeetPublicCompileContracts() {
  requireHashableAndSendable(DesignOSColorRole.self)
  acceptsPublicColorRole(.labelPrimary)
}

private func requireHashableAndSendable<Value: Hashable & Sendable>(_: Value.Type) {}

private func acceptsPublicColorRole(_: DesignOSColorRole) {}
