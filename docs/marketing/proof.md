---
title: Native capture evidence and publication scope
description: Source-bound native fixture evidence, transformations, coverage and verification limits for Apple Design OS.
---

# Native capture evidence and publication scope

The layered implementation is now merged into main through [PR 3](https://github.com/jangtrinh/design-os-apple/pull/3). Tested head [1898ce2](https://github.com/jangtrinh/design-os-apple/tree/1898ce28861d642f57dccd88fd57afcbe3be5bb9), actual test merge `f77ab0e051d22d9c80bc6bd24edf952ffb2bc430`, and merged main `56f10a1` share source tree `d409c1deaa8c4f766916d728b20c53852214d09b`. No tagged release is claimed.

## Current component catalog

[CI run 38157622095](https://github.com/jangtrinh/design-os-apple/actions/runs/38157622095) passed all 23 workflow jobs. Its reviewed image set comprises 360 isolated component captures, 108 screen-family captures and 42 dedicated text-field states across iPhone, iPad and Mac. Accessibility-size and RTL cases occur within the isolated set; these counts are not complete accessibility acceptance.

The [catalog](../components.html) hosts 142 original native iPhone images in 71 light/dark pairs: 106 isolated defaults and 36 screen-family fixtures. Other reviewed platform/state evidence is separate; links to source archives are not hosted previews. There are 99 source entries, including 28 helpers/support/OS-hosted records with separately labeled source diagrams rather than standalone native captures. All 160 token values have source-driven web illustrations and are counted separately.

The [component image manifest](../assets/components/manifest.json) binds every hosted image to original capture and source hashes. Display images are lossless native pixels. Documented crops remove platform framing or exact-uniform trailing blank rows, preserving displayed UI. No generated replacement UI or copied third-party product screenshot is presented as native evidence.

## Historical overview images

The six homepage images and README overview retain their original [adcf88a source](https://github.com/jangtrinh/design-os-apple/tree/adcf88a468a43ed1727c9c902ae5243423e4176e) and [CI run 38087127370](https://github.com/jangtrinh/design-os-apple/actions/runs/38087127370). That historical run passed eight jobs. Its reported package count was 173, with the genuine high-contrast fixture skipped; it is not a claim of 173 fully accepted accessibility tests. The [marketing image manifest](../assets/marketing/manifest.json) records the original transforms, scaling and overview composition. These images are not silently relabeled as current captures.

## Verification boundaries

Source coverage, compiler/tests, fixture execution, image review and full product acceptance are different claims. No screenshot or green run alone establishes every visual state, physical-device behavior, live AI or camera integration, complete VoiceOver behavior, performance or every supported OS version. The native controls and app actions remain caller-owned.

The MIT software license does not grant rights in third-party imagery or products. Published fixtures use original synthetic example content. Source and image provenance remain pinned; private review material is not published.

## Crawlability and machine-readable content

The static catalog includes names, APIs, native images and source links without executing JavaScript. Filters are progressive enhancement. The sitemap advertises the actual HTML routes; canonical metadata and JSON-LD describe visible content. llms.txt and JSON inventories help documentation consumers, without promising eligibility, ranking, indexing or AI citations. A robots.txt served beneath /design-os-apple/ does not control the origin: crawlers consult https://jangtrinh.github.io/robots.txt. Absence of an origin robots file is not a crawl block.
