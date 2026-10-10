# Optional CalorieCam photo-analysis server

Local development integration using the real OpenAI Responses API, image input, and strict structured output. No packages to install; Node.js 22 or later and its standard library are sufficient. This is an optional service, not a bundled recognition model. Manual entry and the explicitly labeled offline demo can work without it.

## Setup (operator action required)

1. Choose a currently available OpenAI model with image-input and Structured Outputs support for your account. Set `OPENAI_MODEL` explicitly; no potentially stale or unexpectedly expensive default is selected. Check [models](https://developers.openai.com/api/docs/models) and current pricing first.
2. Supply your existing `OPENAI_API_KEY` only in the server process environment using your normal secret-management mechanism. Do not put it in Swift code, Xcode project settings, an app bundle, this repository, a URL, or a client request. Do not paste it into chat. This example does not create credentials or save them.
3. In this directory, run `node server.mjs` (or `npm start`). `PORT` defaults to `8787`. The process binds only to `127.0.0.1`; no host override is provided.
4. In a Debug build of CalorieCam, set `CALORIECAM_ANALYSIS_URL=http://127.0.0.1:8787/analyze` and `CALORIECAM_ALLOW_LOCAL_HTTP=1` in the Xcode scheme environment. The opt-in accepts only exact loopback hosts; Release builds require HTTPS. See the [app setup instructions](../README.md). Mac and a simulator on the same Mac can use loopback; loopback on a physical iPhone means the phone, not the Mac. Do not expose this development server to the LAN or public internet to work around that. Real-device or production use needs a separately reviewed HTTPS service with authentication, authorization, abuse protection, operating limits, and privacy controls.
5. Only after reviewing the app's upload confirmation, intentionally request analysis of an image you permit OpenAI to process. API usage may incur charges. No automatic background upload or automatic retry is implemented here.

Both `OPENAI_API_KEY` and `OPENAI_MODEL` are required for analysis. Without either, `/analyze` returns `503 not_configured`; `/health` remains healthy because it reports process liveness, not provider readiness. Model support, account access, pricing, and real food-recognition quality require an operator-authorized live check; they have **not** been verified with a paid API call.

## HTTP contract

`GET /health` → `200 {"status":"ok"}`. No credentials, model selection, or configuration details are disclosed.

`POST /analyze` with `Content-Type: application/json`:

```json
{"imageBase64":"<canonical base64 of image bytes, without a data URL prefix>","mimeType":"image/jpeg"}
```

- Exactly these two properties. JPEG, PNG and WebP accepted; HEIC must be re-encoded by the client.
- At most 5 MiB decoded; JSON body capped at base64 expansion plus 1 KiB.
- Canonical base64 and MIME/file-signature agreement are checked. This standard-library service does not fully decode images: the upstream service must also accept the image. Signature validation is not a guarantee that a file is a well-formed, safe, or recognizable image.
- Client should resize/re-encode selected images before upload to reduce cost and remove metadata. Server forwards the supplied image bytes; it does not strip embedded metadata. Never send a photo containing data the user has not approved sharing.
- Requests with browser Origin headers are rejected, no CORS is enabled, and Host must be a loopback hostname/address to reduce browser and DNS-rebinding abuse. This is not an authentication system or a security boundary against other local processes.
- One active analysis and at most 10 submissions per process per minute; restart resets limits. These are development safeguards, not production quotas.

Success (`200`):

```json
{
  "foods": [{"name":"Rice","portion":"About 1 cup","calories":205}],
  "uncertaintyNote":"Portion size and hidden oil are uncertain. Photo-based calorie estimates can be inaccurate. Review foods, portions, and calories before saving. Not medical advice.",
  "source":"openai",
  "isEstimate":true
}
```

The example above documents the shape, not a guaranteed estimate. The model must return 1–20 reviewable foods; each food has a nonempty name (≤120 characters), portion (≤160 characters), and integer kcal for the entire listed portion (0–10,000), with a meal total no greater than 50,000 kcal. The server adds a fixed caution to the model's uncertainty note (≤600 characters before the caution), and validates the decoded model output independently of Structured Outputs. Foods are never automatically saved.

All errors have the shape:

```json
{"error":{"code":"uncertain","message":"The photo is too uncertain to estimate. Try a clearer photo or enter the meal manually."}}
```

| HTTP | Codes | Meaning |
| --- | --- | --- |
| 400 | `invalid_json`, `invalid_request`, `invalid_image` | Malformed input |
| 403 | `forbidden` | Browser origin or non-loopback Host |
| 404 / 405 | `not_found`, `method_not_allowed` | Unsupported route/method |
| 413 | `image_size`, `body_too_large` | Limit exceeded |
| 415 | `unsupported_image`, `unsupported_content_type` | Unsupported image, encoding or request type |
| 422 | `no_food`, `uncertain` | No usable estimate or model refusal; no fixture fallback |
| 429 | `busy`, `rate_limited` | Wait before trying again |
| 499 | `cancelled` | Request cancelled, if client still connected |
| 502 | `upstream_error`, `invalid_response`, `incomplete_response` | Provider failure or unusable response |
| 503 | `not_configured` | Missing server-side configuration |
| 504 | `timeout` | 45-second upstream deadline |

The service bounds upload duration, upstream duration, and response body size. A disconnected HTTP client aborts the upstream fetch; the provider may already have processed or charged for a request. It does not retry automatically. Provider error bodies, secrets, request payloads, food results, and photo bytes are not logged. Only server startup or a generic startup failure is printed. The service writes no photos or results to disk.

## Privacy and limits

A real analysis request transmits the supplied photo to OpenAI. The service uses `store: false` and makes no Files API upload, but this **does not promise zero provider retention**: applicable abuse-monitoring, image, prompt-caching, and organizational data controls still apply. Review [OpenAI's current data controls](https://developers.openai.com/api/docs/guides/your-data) before enabling. Do not describe real analysis as offline or entirely on-device.

Photographs cannot reliably establish portion weight, hidden ingredients, preparation methods, or energy content. Review and correct every estimate. Results are not medical advice; the service does not supply weight-loss goals or nutrition prescriptions. No-food, ambiguous, refused, incomplete and malformed responses fail explicitly. No claim of measured accuracy, clinical validation, or release readiness is made.

## Verification without credentials or charges

```sh
node --test
```

Tests bind ephemeral loopback HTTP ports and inject a stub `fetch` for the upstream service. They use a synthetic one-pixel PNG, not user data, and never call OpenAI. They verify the full local HTTP request path, Responses request construction, strict output contract, config failure, no-food/uncertain/refusal paths, malformed/oversized inputs and outputs, safe provider errors, local-only browser protections, concurrency/rate limits, timeout and cancellation. Passing these tests verifies wiring and validation, **not** real image-recognition quality or compatibility with a particular model/account.

Protocol sources checked during implementation:
- [Responses image input](https://developers.openai.com/api/docs/guides/images-vision)
- [Structured Outputs (`text.format`, JSON Schema, refusals)](https://developers.openai.com/api/docs/guides/structured-outputs)
- [API data controls](https://developers.openai.com/api/docs/guides/your-data)
