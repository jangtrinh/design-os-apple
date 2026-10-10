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

## Direct personal API keys (BYOK)

`AIProvider` supports `.openAI` and `.claude`. `ProviderConfiguration(provider:modelID:)`
validates and persists only the provider and model ID. No model is selected implicitly.
The app obtains a key from its own Keychain and supplies it only in memory to
`ProviderMealAnalyzer(configuration:apiKey:)`. The analyzer must be short-lived and
must never be logged. Its ordinary description/reflection redacts stored state.
Developer/service keys must never ship inside the app.

- `verifyConnection()` performs a metadata-only GET on the official provider model
  endpoint. It returns `ProviderModelInfo`, verifies key/model access, and sends no
  photograph or generation request. It does not prove image support, structured
  output compatibility, generation quota, or estimate accuracy.
- `analyze(imageData:)` requires explicit provider-named upload consent and a
  normalized JPEG (complete SOI/EOI signature, up to 5 MiB). It sends one structured
  vision request; the provider may bill the user's API account.
- Each request uses a fresh ephemeral 45-second URLSession, no URL cache, shared
  credentials or cookies. Redirects are blocked. Responses are capped at 256 KiB
  while receiving. There are no automatic retries, fallback providers or models.
- Caller cancellation cancels the network task. App settings changes should cancel
  an in-flight operation and disregard stale results.
- Remote error bodies are never displayed or logged. Estimates require a finished
  provider response, exactly one JSON text result, expected keys, valid status,
  nonempty bounded text, up to 20 foods, integer calories 0–10,000 per item, and a
  maximum 50,000 total. No-food, uncertainty, refusal, truncation and malformed data
  are errors, never fabricated demo results. Successful estimates retain `.remote`
  origin and must be reviewed before saving.
- No photo bytes, keys or provider response envelopes are written to disk. Provider
  retention is separate from app storage; OpenAI uses `store: false`, which is not
  a blanket promise of zero provider retention.

The existing backend-only `RemoteMealAnalyzer` remains available unchanged. Direct
BYOK's connection and analysis contracts have credential-free injected-transport
and URLProtocol fixtures. Native Swift execution is still required to establish
passing evidence; no real-key/live-provider test was performed in authoring.

API assumptions and dated official references: [provider API reference](../../../docs/provider-api-reference.md).
