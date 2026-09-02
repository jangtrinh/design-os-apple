#!/usr/bin/env node

import { execFileSync } from "node:child_process"
import { copyFileSync, existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs"
import { basename, dirname, join, resolve } from "node:path"
import { assetName, buildPrompt, CATALOG_THUMBNAIL_SLOTS } from "./catalog-thumbnail-slots.mjs"

const projectRoot = resolve(import.meta.dirname, "..")
const assetCatalog = join(
  projectRoot,
  "Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets",
)
const archiveRoot = join(projectRoot, "design/asset-archive/catalog-thumbnails/latest")
const expectedWidth = 1200
const expectedHeight = 900

function fail(message) {
  console.error(message)
  process.exit(1)
}

function ensureAssetCatalog() {
  mkdirSync(assetCatalog, { recursive: true })
  writeFileSync(
    join(assetCatalog, "Contents.json"),
    `${JSON.stringify({ info: { author: "xcode", version: 1 } }, null, 2)}\n`,
  )
}

function imageSetPath(storyID) {
  return join(assetCatalog, `${assetName(storyID)}.imageset`)
}

function imagePath(storyID) {
  return join(imageSetPath(storyID), `${assetName(storyID)}.png`)
}

function writeImageSetContents(storyID) {
  const contents = {
    images: [
      { filename: `${assetName(storyID)}.png`, idiom: "universal", scale: "1x" },
      { idiom: "universal", scale: "2x" },
      { idiom: "universal", scale: "3x" },
    ],
    info: { author: "xcode", version: 1 },
    properties: { "preserves-vector-representation": false },
  }
  writeFileSync(join(imageSetPath(storyID), "Contents.json"), `${JSON.stringify(contents, null, 2)}\n`)
}

function dimensions(path) {
  return execFileSync("magick", ["identify", "-format", "%w %h", path], {
    encoding: "utf8",
  })
    .trim()
    .split(" ")
    .map(Number)
}

function ingest(storyID, sourcePath) {
  if (!CATALOG_THUMBNAIL_SLOTS[storyID]) fail(`Unknown story ID: ${storyID}`)
  const source = resolve(sourcePath)
  if (!existsSync(source)) fail(`Generated image does not exist: ${source}`)

  ensureAssetCatalog()
  mkdirSync(imageSetPath(storyID), { recursive: true })
  const destination = imagePath(storyID)
  if (existsSync(destination)) {
    mkdirSync(archiveRoot, { recursive: true })
    copyFileSync(destination, join(archiveRoot, `${assetName(storyID)}.png`))
  }

  execFileSync("magick", [
    source,
    "-auto-orient",
    "-resize",
    `${expectedWidth}x${expectedHeight}^`,
    "-gravity",
    "center",
    "-extent",
    `${expectedWidth}x${expectedHeight}`,
    "-strip",
    `PNG24:${destination}`,
  ])
  writeImageSetContents(storyID)
  console.log(`${storyID} -> ${destination}`)
}

function verify() {
  if (!existsSync(assetCatalog)) fail(`Missing asset catalog: ${assetCatalog}`)
  const storyIDs = Object.keys(CATALOG_THUMBNAIL_SLOTS)
  const expectedSets = new Set(storyIDs.map((storyID) => `${assetName(storyID)}.imageset`))
  const actualSets = new Set(
    readdirSync(assetCatalog, { withFileTypes: true })
      .filter((entry) => entry.isDirectory() && entry.name.endsWith(".imageset"))
      .map((entry) => entry.name),
  )

  const missing = [...expectedSets].filter((name) => !actualSets.has(name))
  const unexpected = [...actualSets].filter((name) => !expectedSets.has(name))
  if (missing.length || unexpected.length) {
    fail(`Asset set mismatch. Missing: ${missing.join(", ") || "none"}; unexpected: ${unexpected.join(", ") || "none"}`)
  }

  for (const storyID of storyIDs) {
    const path = imagePath(storyID)
    if (!existsSync(path)) fail(`Missing generated thumbnail: ${path}`)
    const [width, height] = dimensions(path)
    if (width !== expectedWidth || height !== expectedHeight) {
      fail(`${storyID} is ${width}x${height}; expected ${expectedWidth}x${expectedHeight}`)
    }
    const contentsPath = join(imageSetPath(storyID), "Contents.json")
    const contents = JSON.parse(readFileSync(contentsPath, "utf8"))
    if (contents.images?.[0]?.filename !== basename(path)) {
      fail(`${storyID} Contents.json does not reference ${basename(path)}`)
    }
  }
  console.log(`Verified ${storyIDs.length} generated catalog thumbnails at 1200x900.`)
}

function printPrompts(storyIDs) {
  const selected = storyIDs.length ? storyIDs : Object.keys(CATALOG_THUMBNAIL_SLOTS)
  for (const storyID of selected) {
    console.log(`\n### ${storyID}\n${buildPrompt(storyID)}\n`)
  }
}

const [command, ...args] = process.argv.slice(2)
switch (command) {
  case "prompt":
    printPrompts(args)
    break
  case "ingest":
    if (args.length !== 2) fail("Usage: generate-catalog-thumbnails.mjs ingest <story-id> <png>")
    ingest(args[0], args[1])
    break
  case "verify":
    verify()
    break
  case "reset-assets":
    if (args.length !== 1 || args[0] !== "--confirm-empty-generated-assets") {
      fail("Refusing reset without --confirm-empty-generated-assets")
    }
    rmSync(assetCatalog, { recursive: true, force: true })
    ensureAssetCatalog()
    console.log(`Reset generated asset catalog: ${assetCatalog}`)
    break
  default:
    fail("Usage: generate-catalog-thumbnails.mjs <prompt [story-id...] | ingest <story-id> <png> | verify>")
}
