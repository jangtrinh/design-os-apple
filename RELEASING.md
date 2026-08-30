# Releasing

No public remote or tagged release is authorized yet. The current deliverable is a local
`0.1.0-rc.1` candidate.

## Prepare a candidate

1. Update user-visible changes in `CHANGELOG.md`.
2. Run `scripts/verify-release-candidate.sh` after the final source or documentation edit.
3. Review the exact public file list from `scripts/list-public-release-files.sh`.
4. Run `scripts/verify-publication-boundary.sh --staged` after staging only reviewed paths.
5. Record independent review and every manual/device/owner gate as passed or `NOT VERIFIED`.

Never use broad staging as a release decision. The allowlist is an explicit candidate set;
the staged verifier is the final local publication boundary.

## Publish only after explicit authorization

Publishing requires a confirmed repository owner, repository name, visibility, remote URL,
public-name/trademark disposition, disclosure set, version, and owner acceptance. Re-run the
same gates on the exact commit after any rebase. Then create a signed or annotated tag and a
release whose notes match `CHANGELOG.md`. Remote creation, push, tag, and release are outside
the local candidate workflow until those decisions are explicit.
