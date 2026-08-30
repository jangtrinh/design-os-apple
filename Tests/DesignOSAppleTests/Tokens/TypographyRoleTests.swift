import DesignOSApple
import Testing

@Test("Typography roles are unique semantic values")
func typographyRolesAreUnique() {
  let roles: [DesignOSTypographyRole] = [
    .largeTitle, .title, .title2, .title3, .headline, .subheadline,
    .body, .callout, .footnote, .caption, .caption2,
  ]

  #expect(roles.count == 11)
  #expect(Set(roles).count == roles.count)
}

@Test("Typography transformations are idempotent semantic intent")
func typographyTransformationsAreIdempotent() {
  let body = DesignOSTypographyRole.body

  #expect(body.emphasized() != body)
  #expect(body.italic() != body)
  #expect(body.emphasized().emphasized() == body.emphasized())
  #expect(body.italic().italic() == body.italic())
  #expect(body.emphasized().italic() == body.italic().emphasized())
}

@Test("Typography roles meet immutable public compile contracts")
func typographyRolesMeetPublicCompileContracts() {
  requireHashableAndSendable(DesignOSTypographyRole.self)
  acceptsPublicTypographyRole(.body)
}

private func requireHashableAndSendable<Value: Hashable & Sendable>(_: Value.Type) {}

private func acceptsPublicTypographyRole(_: DesignOSTypographyRole) {}
