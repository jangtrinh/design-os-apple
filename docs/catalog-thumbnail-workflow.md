# Catalog thumbnail workflow

The Gallery uses one generated UI illustration for every admitted story. These images are
decorative navigation art. They are not screenshots, executable UI, platform-conformance
evidence, or substitutes for each story's live SwiftUI preview.

The closed slot registry and shared prompt live in
`scripts/catalog-thumbnail-slots.mjs`. Every asset is normalized to 1200x900, stored in
`Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets`, and addressed from
SwiftUI by its stable story ID.

## Regenerate one thumbnail

1. Print the story-specific prompt:

   ```bash
   node scripts/generate-catalog-thumbnails.mjs prompt foundation.color-roles
   ```

2. Generate an original image with the approved image model. Reference images may guide
   visual style only; never copy screenshots, third-party brand assets, or product artwork.

3. Ingest and normalize the generated PNG:

   ```bash
   node scripts/generate-catalog-thumbnails.mjs ingest \
     foundation.color-roles /absolute/path/to/generated.png
   ```

4. Verify the exact story-to-asset set and dimensions:

   ```bash
   node scripts/generate-catalog-thumbnails.mjs verify
   ```

Ingestion archives an existing asset before replacement. The verifier fails on a missing,
unexpected, incorrectly named, or incorrectly sized image set. ImageMagick's `magick`
binary is required for ingestion and verification.

## Local-demo generated art

The six mini apps use six original GPT Image 2 catalog thumbnails. Visual Assistant,
Streaming Library, Song Finder, and City Ride also use original runtime-media assets. These
ten files are Gallery-only illustration, not reference screenshots, copied product art,
or package runtime resources. Their closed provenance contract lives in
`Examples/DesignOSAppleGallery/Generated/local-demo-image-provenance.v1.json`.

Verify the exact paths, hashes, PNG structure, dimensions, asset-catalog membership, and
package boundary with:

```bash
node scripts/verify-local-demo-image-provenance.mjs --root .
```

Publication admits only the ten manifest-bound files as `gallery-generated-art`, with a
3 MiB per-file and 20 MiB aggregate ceiling. The default 1 MiB public-file ceiling remains
unchanged for every other asset. Passing this machine gate proves identity and packaging;
it does not establish legal clearance, owner acceptance, or publication authorization.
