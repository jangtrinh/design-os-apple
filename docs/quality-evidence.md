# Quality Evidence

Quality claims are separated because one green gate cannot stand in for another.

## Deterministic local and CI gates

`scripts/verify-release-candidate.sh` owns the reproducible command composition. It checks
the Swift package, strict concurrency release build, formatting, DocC compilation, catalog
bundle drift, consumer snippet, public-file boundary, and feasible Gallery build/smoke.
GitHub Actions calls the same script.

### Release compilation verification & test suite evolution

- **Historical initial failure:** Under baseline Apple Swift 6.2.3, release-mode compilation (`-O`) encountered a fatal `CopyPropagation` SIL compiler crash in `DesignOSStoryDescriptor.init(from:)`, while 90 unit tests passed under debug compilation.
- **Workaround:** A minimal, source-preserving memberwise initialization in `DesignOSStoryDescriptor.swift` avoids the observed `CopyPropagation` compiler crash during property evaluation (the underlying compiler-internal mechanism remains unproven). Optimization (`-O`) and strict concurrency flags remain fully enabled.
- **Verification evidence:**
  - Unchanged strict release build (`swift build -c release -Xswiftc -strict-concurrency=complete -Xswiftc -warnings-as-errors`) passed cleanly.
  - All 91 package tests passed in debug configuration (historical 90 plus 1 targeted descriptor decoding regression suite covering validation precedence and compatibility bounds).
  - The targeted decoder regression was executed and passed release optimization.

## Evidence not implied by CI

- Simulator or hosted Gallery checks do not prove physical-device behavior.
- Automated accessibility assertions do not prove a manual VoiceOver journey.
- Build success does not prove layout quality, animation quality, or platform taste.
- Implementer verification does not replace independent review.
- Technical evidence does not replace owner-visible acceptance or release authorization.

Record those results with the device, OS, input mode, Dynamic Type size, window conditions,
and exact story route. A missing result remains `NOT VERIFIED`; it is never promoted from a
different green check.
