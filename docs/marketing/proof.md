# Marketing proof and publication scope

This page describes the evidence behind the README and GitHub Pages kit preview. It is not a release certificate or an assertion of complete visual acceptance.

## Source and availability

- Candidate source: [`adcf88a468a43ed1727c9c902ae5243423e4176e`](https://github.com/jangtrinh/design-os-apple/tree/adcf88a468a43ed1727c9c902ae5243423e4176e).
- Candidate review: [pull request 3](https://github.com/jangtrinh/design-os-apple/pull/3).
- Native verification: [CI run 38087127370](https://github.com/jangtrinh/design-os-apple/actions/runs/38087127370), candidate `adcf88a`, tested merge `86b686d`.
- Publication scope: README, Pages presentation, selected screenshots, and provenance. Publishing these documents does not merge the candidate implementation into main.
- Consumers wanting the new kit must pin the candidate revision. The [main quickstart](https://github.com/jangtrinh/design-os-apple/blob/main/docs/getting-started.md) remains available for the existing library.

## Claim register

| Published statement | Evidence and limit |
| --- | --- |
| Swift 6.2; iOS/iPadOS 17 and macOS 14 minimum; no external package dependencies | [Candidate Package.swift](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/Package.swift). Platform floors are not a claim of execution on every OS version. |
| 42 additive public APIs | 4 semantic + 11 composite + 9 shell + 18 screen APIs in the [candidate architecture](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/luma-kit-architecture.md) and [source index](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/layered-kit-index.json). |
| 3 new internal helpers; 4 further native/existing-component recipes | Counted separately from the 42 APIs. Internal measurement helpers do not become public APIs for marketing purposes. |
| Unified application style and continuous/pill geometry | [Style contract and source links](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/reusable-app-style.md). Continuous corners are this project's design rule, not an Apple-mandated universal radius. |
| 393 reference states mapped | [Atlas](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/luma-layout-atlas.md). Research mapping is not complete reconstruction or visual acceptance. |
| 8 CI jobs passed | [Run 38087127370](https://github.com/jangtrinh/design-os-apple/actions/runs/38087127370). Historical result for the named revision, not a guarantee about later revisions or all behaviors. |
| CalorieCam 10/10 and kit 9/9 on each of iPhone, iPad, Mac | Reported native UI suites from the named run. CalorieCam is an app example, not a package API. |
| 173 reported package tests | Native package report, with the genuine high-contrast fixture skipped. The count must not be rendered as “173 passed with full accessibility proof.” |
| 108 native family captures | Original family artifacts from the named run. Selected captures on this site are resized/cropped/composed only as recorded in the [asset manifest](../assets/marketing/manifest.json). |

## Screenshot provenance

The [asset manifest](../assets/marketing/manifest.json) records source paths, dimensions, transformations, and source binding. Gallery pictures are actual native fixtures, not AI-generated UI or copied reference-app assets. The overview is an editorial composition of native captures; it is not one simultaneously running app screen. Mac imagery may be cropped to the app window, as recorded in the manifest.

Screenshots demonstrate selected visible family states. They do not prove every source state, interaction, accessibility mode, display size, or platform configuration.

## Known limits

Earlier intermittent control-activation failures remain unexplained. One successful verification run is useful evidence, but does not establish that those failures were repaired.

The marketing preview makes no claim of:

- complete reconstruction or visual acceptance of all 393 reference states;
- live AI inference or physical-camera acceptance;
- OS 27 / iPhone Duo native execution;
- complete VoiceOver validation, genuine high-contrast fixture coverage, or performance results;
- a tagged release, a production-readiness guarantee, or Apple endorsement.

## Documentation routes

Existing package: [Getting Started](https://github.com/jangtrinh/design-os-apple/blob/main/docs/getting-started.md), [DocC](https://github.com/jangtrinh/design-os-apple/blob/main/Sources/DesignOSApple/DesignOSApple.docc/DesignOSApple.md), [Quality Evidence](https://github.com/jangtrinh/design-os-apple/blob/main/docs/quality-evidence.md), [Portable verification](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/portable-verification.md).

Candidate-specific: [architecture](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/luma-kit-architecture.md), [index](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/layered-kit-index.json), [theme and geometry](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/reusable-app-style.md), [native recipes](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/native-layout-recipes.md), [ownership](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/design-system-organization.md), [reference atlas](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/luma-layout-atlas.md), [native API coverage](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/component-coverage.md), [CalorieCam](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/Examples/CalorieCam/README.md).

Maintainer routes: [catalog thumbnail workflow](https://github.com/jangtrinh/design-os-apple/blob/main/docs/catalog-thumbnail-workflow.md), [reference reconstruction](https://github.com/jangtrinh/design-os-apple/blob/adcf88a468a43ed1727c9c902ae5243423e4176e/docs/reference-reconstruction-workflow.md), [release process](https://github.com/jangtrinh/design-os-apple/blob/main/RELEASING.md), [contributing](https://github.com/jangtrinh/design-os-apple/blob/main/CONTRIBUTING.md).

## Page foundation and privacy

The page adapts the nine-tier architecture from [design-os-github-page revision d45be6a](https://github.com/jangtrinh/design-os-github-page/tree/d45be6a73af64ff7407d0a98dc3a3d980f00e05c): hero, facts, honest comparison, install, safe-use loop, gallery/evidence, FAQ, ecosystem, and documentation routes. Its [MIT license](https://github.com/jangtrinh/design-os-github-page/blob/d45be6a73af64ff7407d0a98dc3a3d980f00e05c/LICENSE) applies to reused template material.

The landing page uses local CSS, system fonts, and local images, with no third-party script. This README loads external Shields badge images; the existing Markdown document layout retains an external Buy Me a Coffee widget. These are separate from the Swift package's no-first-party-telemetry behavior.
