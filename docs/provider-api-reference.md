# CalorieCam direct-provider API reference

Research date: **2026-10-10 (UTC)**. The official pages below were checked after
reviewing CalorieCam's existing OpenAI server implementation. No real API key,
photo, live inference, paid call, or live authentication test was used.

## Stable app contract

The native settings layer owns user-entered API keys in Keychain. Core receives a
key only in memory for one short-lived `ProviderMealAnalyzer`. Persistable
`ProviderConfiguration` includes only `provider` and `modelID`.

```swift
let configuration = try ProviderConfiguration(provider: .openAI, modelID: userSelectedModel)
let analyzer = try ProviderMealAnalyzer(configuration: configuration, apiKey: keyFromKeychain)
let metadata = try await analyzer.verifyConnection() // explicit Test Connection action
// Separately, after explicit provider-specific photo-upload consent:
let estimate = try await analyzer.analyze(imageData: normalizedJPEG)
```

The same interface supports `.claude`. Provider selection has no implicit default
model, model upgrade, alternate host, provider fallback, automatic retry, or free
trial assumption. Model IDs must be 1–200 ASCII letters, digits, `-`, `.`, `_`, or
`:`, excluding the complete IDs `.` and `..`. API keys must be nonempty printable
ASCII, up to 512 bytes after trimming surrounding whitespace.

## OpenAI

- Analysis: `POST https://api.openai.com/v1/responses` with Bearer authentication,
  a user `input_image` data URL containing JPEG base64, and a short text prompt.
  The [official vision guide](https://developers.openai.com/api/docs/guides/images-vision)
  documents this Responses input shape.
- Structured output: `text.format` uses `type: json_schema`, `name: meal_estimate`,
  `strict: true`, and the shared schema. The implementation verifies response
  status, the assistant message, refusal, and its single output text before parsing.
  [Structured outputs](https://developers.openai.com/api/docs/guides/structured-outputs)
  documents this route and the need to handle refusal and incomplete output.
- Connection check: `GET https://api.openai.com/v1/models/{modelID}` uses the same
  Bearer header, no request body, photo or generation. The
  [retrieve-model reference](https://developers.openai.com/api/reference/resources/models/methods/retrieve)
  describes model metadata and access, not a proof that all inference features work.
- The generation request sets `store: false` and `max_output_tokens: 4000`.
  This app flag is not a guarantee that the provider retains no data under its
  applicable API terms and policies.

## Claude / Anthropic

- Analysis: `POST https://api.anthropic.com/v1/messages` with `x-api-key` and
  `anthropic-version: 2023-06-01`. The JPEG is an image content block with a base64
  source, `media_type: image/jpeg`, followed by a text block. See the
  [official vision guide](https://platform.claude.com/docs/en/build-with-claude/vision).
- Structured output: `output_config.format` uses `type: json_schema` and the
  shared schema. The [official structured-output guide](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)
  documents this current non-beta shape. Core does not use the deprecated
  `output_format` or an invented provider-neutral API field. JSON Schema features
  differ by provider; the shared schema uses types, enums, required fields and
  `additionalProperties: false`. All numeric, text and array limits are also
  validated in Swift. Only `end_turn` with one text block is accepted; `refusal`
  and `max_tokens` are handled without a generation retry. `max_tokens` is 4000.
- Connection check: `GET https://api.anthropic.com/v1/models/{modelID}` with the same
  API headers. [Get a Model](https://platform.claude.com/docs/en/api/models/retrieve)
  documents metadata lookup and model alias resolution. The UI may display the
  returned canonical ID/name, but must not silently overwrite the saved model.

## What Test Connection proves

The user-specified key can retrieve metadata for the selected model from that
provider at that moment. It sends no photo and invokes no inference endpoint.
It does **not** prove generation billing/quota, image input, structured JSON support,
or meal-estimate accuracy. Users must choose a model supporting both vision and
structured output. A real analysis rejected by the provider reports that limitation
and preserves the user's selected provider/model; it never switches silently.

## Transport and result safety

Both hosts are fixed constants. A model ID cannot add path segments, a query, a
fragment or credentials to the URL. Authentication exists only in its provider's
header; not in settings, model input, URLs, errors, logs or the journal.

Each request uses a fresh ephemeral session with a 45-second request/resource
limit, no cookie storage, no URL cache, and no shared URL credential storage.
Redirects, including redirects to the same host, are rejected. The received buffer
is limited to 256 KiB incrementally, with a separate Content-Length check. Caller
cancellation invalidates the session; no automatic retry occurs. System TLS
validation is unchanged. This is memory-only handling, not a claim of provable
cryptographic memory zeroization.

Input is a complete JPEG signature, at most 5 MiB; the app normalizes and decodes
its selected image before calling Core. Core does not decode arbitrary image
formats, open image URLs, or persist images. OpenAI and Claude may process/retain
uploads under their own policies, as disclosed by the app before analysis.

A result must contain exactly `status`, `foods`, and `uncertaintyNote`. Each food
has exactly `name`, `portion`, and integer `calories`. Validation bounds are 20
foods, 120-character names, 160-character portions, 600-character uncertainty note,
0–10,000 kcal per item, and at most 50,000 kcal total. Text must be nonblank and
contain no control characters. Non-estimate statuses require empty foods. These
limits defend data quality; they are not nutrition recommendations. Returned
`MealEstimate` values retain `.remote` origin, add a review disclaimer, and remain
unsaved until the user reviews and confirms them.

## Verification status

Credential-free source tests cover both provider request shapes and successful
estimates, metadata-only checks, malformed input, strict response validation,
refusal/truncation, auth/permission/rate/server failures, redacted errors and object
descriptions, pre-cancellation and in-flight cancellation, blocked redirects,
incremental response bounds, and disabled caching/credential storage. All fixtures
use injected transports or URLProtocol; they never contact either provider.

Run `swift test --package-path Examples/CalorieCam/Core` on Swift 6.2 or later.
The authoring Linux environment had no Swift compiler; tests require native CI
before claiming a passing build. A fixture pass is not live API compatibility
verification. Real-account setup and any paid analysis remain user-owned actions.
