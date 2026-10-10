# Portable documentation and provenance verification

These checks protect the public onboarding example and knowledge provenance on macOS
or Linux. They require Python 3.9 or newer and use only the Python standard library.
They do not build the SwiftUI package or run Apple simulator tests.

## Public quickstart

```bash
python3 scripts/test-quickstart-parity.py
python3 scripts/verify-quickstart-parity.py
```

The parity check compares the bounded Swift example in `getting-started.md` with the
bounded HTML example on `index.html`, decoding HTML entities before comparison. Missing
or ambiguous examples and code drift are failures. A matching example is not evidence
that the Swift code compiles.

On macOS, `scripts/verify-consumer-quickstart.sh` runs this parity check before the existing
package build and Swift typecheck. The release-candidate gate still requires those native
checks; the portable CI job is additional coverage, not a replacement.

## Provenance regression suite

```bash
python3 scripts/test-ukmc-verifier.py
```

The suite creates temporary copies and explicitly tests local validation independently of
an installed knowledge-builder. Its negative controls include malformed secondary source
anchors, quoted quarantine booleans, invalid manifests, source paths outside the corpus,
invalid relationships, and strict-index integrity. Rejected inputs must not rewrite the
index. Separate checks verify that the default CLI fails closed without its canonical
dependency and that an explicit local fallback does not claim canonical validation.

## Canonical knowledge-builder integration

Use a reviewed checkout of
[design-os-knowledge-builder](https://github.com/jangtrinh/design-os-knowledge-builder).
Record its commit when reporting results. Point to its `src` directory, not its repository
root:

```bash
python3 scripts/verify-ukmc-corpus.py --check \
  --knowledge-builder-src /path/to/design-os-knowledge-builder/src
```

Alternatively set `UKMC_KNOWLEDGE_BUILDER_SRC`. An explicit command-line path takes
precedence over the environment variable. With neither set, the verifier retains the
legacy sibling `../knowledge-builder/src` lookup. Missing or unloadable canonical code
is a failure by default; installing this external dependency is not automatic.

For a deliberately limited local check without that dependency:

```bash
python3 scripts/verify-ukmc-corpus.py --check --allow-fallback
```

When the canonical contract is unavailable, a successful fallback is labeled
`LOCAL CHECKS PASSED` and `Canonical contract validation NOT VERIFIED`. Do not report it
as canonical-contract or native-runtime acceptance. Use `--check` to keep verification
read-only; omitting it requests index generation after successful validation.

## CI scope

The Linux `portable-contracts` job runs both regression suites and quickstart parity.
The existing macOS `release-candidate` job remains responsible for Swift, DocC, catalog,
publication and Gallery checks. Manual accessibility, visual review, physical-device
behavior and owner acceptance remain separate evidence requirements.
