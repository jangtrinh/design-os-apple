# Security Policy

## Supported versions

This project has no public tagged release yet. Security fixes target the current release
candidate source. A version support table will begin with the first published release.

## Report a vulnerability

Use GitHub private vulnerability reporting when the repository enables it. If that route is
not available, open a non-sensitive issue requesting private maintainer contact. Do not put
exploit details, secrets, personal data, or affected-user data in a public issue.

Include the affected product and platform, impact, minimal reproduction, and whether the
issue requires a malicious app, crafted catalog input, or local filesystem access. The
maintainer will acknowledge the report, reproduce it, assess affected versions, coordinate
a fix, and credit the reporter unless anonymity is requested.

The package contains no network service or credential store. Its main security boundaries
are package integrity, fail-closed catalog input, publication hygiene, and avoiding unsafe
claims about Apple-owned assets or platform behavior.
