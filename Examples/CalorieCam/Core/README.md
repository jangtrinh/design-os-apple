# CalorieCamCore

Foundation-only Swift 6.2 package for the CalorieCam example. No SwiftUI, cloud SDK,
embedded credentials, photo persistence, health goals, or body data. Values are explicitly
estimates and must be reviewed; this package does not provide nutrition advice.

## Contracts

- `FoodItem`, `MealEstimate`, and `MealEntry` are mutable, Codable, Sendable values.
  Incomplete edits are allowed in memory. Call `validate()` before accepting an edit.
- `EstimateOrigin` preserves `.demo`, `.manual`, or `.remote` provenance. Editing a
  demo must not silently claim that its foods were recognized from a photo.
- `MealAnalyzing.analyze(imageData:)` is the injectable async analysis boundary.
  `DemoMealAnalyzer` does **not** inspect photos. Its rice/chicken/vegetable result
  is a clearly marked fixed fixture.
- `RemoteMealAnalyzer(endpoint:session:allowLocalhostHTTP:)` is an optional upload
  adapter, disabled until the host configures it. The host must obtain explicit
  photo-upload consent naming the backend and OpenAI before invoking it. It accepts
  normalized JPEG only (up to 5 MiB), rejects redirects, and makes one request with
  a 45-second timeout. HTTPS is required, except exact loopback addresses when
  localhost development is explicitly enabled. No client API key is used.
- `MealJournal(url:)` loads and saves an entire journal. Calls must be serialized by
  one owning actor. The host chooses an application-support URL and must only update
  its saved in-memory state after `save` succeeds.
- A missing file starts empty. Unreadable, corrupt, semantically invalid, and
  unsupported-version files throw actionable errors. The host must block saving
  after a load error until the underlying problem is resolved; loading never resets
  or overwrites an existing file. Recovery is intentionally a user-owned action.
- Save validates and encodes first, then atomically replaces the file. No photograph
  bytes or paths are stored. Foundation's atomic write avoids partially written JSON;
  this is not a multi-process database or a guarantee against physical disk failure.

Validation rejects blank food names, empty meals, duplicate identifiers, non-finite
values, negative calories, values over 10,000 per item or 50,000 per meal, and invalid
dates. These upper limits are defensive data-quality bounds, not dietary guidance.

## Verify

On a machine with Swift 6.2 or later:

```sh
swift test --package-path Examples/CalorieCam/Core
```

Tests cover editing and derived totals, input bounds, missing and invalid journals,
provenance-preserving round trips, deletion via whole-array saves, failed-save
preservation, unsupported formats, explicit fixture behavior, and cancellation. URLProtocol fixtures also cover the remote request contract,
endpoint validation, upload bounds, malformed estimates, HTTP and transport errors,
and cancellation without live requests or paid AI calls.

Build and execution status must be recorded separately from source review. The
initial authoring environment had no Swift toolchain, so these tests were **NOT
VERIFIED** there. CI or a local macOS run must establish passing executable evidence.
