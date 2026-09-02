#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const galleryRoot = "Examples/DesignOSAppleGallery";
const manifestRelative = `${galleryRoot}/Generated/local-demo-catalog.v2.json`;
const expectedIDs = [
  "demo.assistant.thoughtful-chat",
  "demo.assistant.visual",
  "demo.mobility.flight-tracker",
  "demo.mobility.city-ride",
  "demo.entertainment.streaming-library",
  "demo.entertainment.song-finder",
];
const expectedSections = ["Assistants", "Assistants", "Mobility", "Mobility", "Entertainment", "Entertainment"];
const expectedAssets = new Set([
  "demo-thoughtful-chat-thumbnail",
  "demo-visual-assistant-thumbnail",
  "demo-flight-tracker-thumbnail",
  "demo-city-ride-thumbnail",
  "demo-streaming-library-thumbnail",
  "demo-song-finder-thumbnail",
  "visual-assistant-answer-art",
  "streaming-library-poster-atlas",
  "song-finder-afterglow-cover",
  "city-ride-arrival-essentials",
]);
const forbiddenBrands = ["Claude", "Gemini", "Flighty", "Grab", "Netflix", "Shazam"];

function fail(message) {
  throw new Error(`E_LOCAL_DEMO_CATALOG: ${message}`);
}

function assert(condition, message) {
  if (!condition) fail(message);
}

function regularFile(root, relativePath) {
  const absolutePath = path.join(root, relativePath);
  let metadata;
  try {
    metadata = fs.lstatSync(absolutePath);
  } catch (error) {
    if (error.code === "ENOENT") fail(`missing file '${relativePath}'`);
    fail(`cannot inspect '${relativePath}': ${error.message}`);
  }
  assert(metadata.isFile() && !metadata.isSymbolicLink(), `nonregular or symlinked '${relativePath}'`);
  assert(fs.realpathSync(absolutePath) === absolutePath, `symlink-resolved '${relativePath}'`);
  return absolutePath;
}

function readJSON(root, relativePath) {
  const absolutePath = regularFile(root, relativePath);
  try {
    return JSON.parse(fs.readFileSync(absolutePath, "utf8"));
  } catch (error) {
    fail(`invalid JSON '${relativePath}': ${error.message}`);
  }
}

function main() {
  assert(process.argv.length === 4 && process.argv[2] === "--root", "usage: verify-local-demo-catalog.mjs --root <project-root>");
  const root = fs.realpathSync(path.resolve(process.argv[3]));
  const manifest = readJSON(root, manifestRelative);
  assert(manifest.schemaVersion === 2, "schemaVersion must be 2");
  assert(manifest.distribution === "localOnly", "top-level distribution mismatch");
  assert(Array.isArray(manifest.demos) && manifest.demos.length === 6, "manifest must contain exactly six demos");

  const ids = manifest.demos.map((demo) => demo.id);
  assert(JSON.stringify(ids) === JSON.stringify(expectedIDs), "demo ID or order mismatch");
  assert(new Set(ids).size === ids.length, "duplicate demo ID");
  assert(JSON.stringify(manifest.demos.map((demo) => demo.section)) === JSON.stringify(expectedSections), "section order or cardinality mismatch");

  const stateIDs = [];
  const stateViews = [];
  const assetNames = new Set();
  const sourcePaths = new Set();
  for (const demo of manifest.demos) {
    assert(demo.distribution === "localOnly", `distribution mismatch for '${demo.id}'`);
    assert(JSON.stringify(demo.platforms) === JSON.stringify(["iOS", "iPadOS", "macOS"]), `platforms mismatch for '${demo.id}'`);
    assert(Array.isArray(demo.states) && demo.states.length === 2, `demo '${demo.id}' must contain exactly two states`);
    assert(typeof demo.entryDestination === "string" && typeof demo.detailDestination === "string", `missing routes for '${demo.id}'`);
    assert(Array.isArray(demo.sourcePaths) && demo.sourcePaths.length > 0, `missing source paths for '${demo.id}'`);
    assert(Array.isArray(demo.assetNames) && demo.assetNames.includes(demo.imageAssetName), `thumbnail not admitted for '${demo.id}'`);
    for (const state of demo.states) {
      assert(typeof state.id === "string" && typeof state.view === "string", `malformed state for '${demo.id}'`);
      stateIDs.push(state.id);
      stateViews.push(state.view);
    }
    for (const sourcePath of demo.sourcePaths) {
      assert(sourcePath.startsWith("App/Shared/Flows/"), `source outside local-demo boundary '${sourcePath}'`);
      regularFile(root, `${galleryRoot}/${sourcePath}`);
      sourcePaths.add(sourcePath);
    }
    for (const assetName of demo.assetNames) assetNames.add(assetName);
  }

  assert(stateIDs.length === 12 && new Set(stateIDs).size === 12, "state IDs must be exactly twelve and unique");
  assert(stateViews.length === 12 && new Set(stateViews).size === 11, "twelve states must resolve to eleven views because Streaming Library owns two scroll positions on one page");
  const streaming = manifest.demos.find((demo) => demo.id === "demo.entertainment.streaming-library");
  assert(streaming.states[0].view === streaming.states[1].view, "Streaming Library states must share one view");
  assert(streaming.entryDestination === streaming.detailDestination, "Streaming Library states must share one route");
  assert(assetNames.size === expectedAssets.size && [...assetNames].every((name) => expectedAssets.has(name)), "asset-name set mismatch");

  const manifestText = JSON.stringify(manifest);
  assert(!forbiddenBrands.some((brand) => manifestText.includes(brand)), "manifest contains a protected reference brand");
  for (const sourcePath of sourcePaths) {
    const source = fs.readFileSync(path.join(root, galleryRoot, sourcePath), "utf8");
    assert(!forbiddenBrands.some((brand) => source.includes(brand)), `source contains a protected reference brand '${sourcePath}'`);
  }

  const registryFiles = ["LocalDemoDefinitions+Assistants.swift", "LocalDemoDefinitions+Mobility.swift", "LocalDemoDefinitions+Entertainment.swift"];
  const registry = registryFiles.map((file) => fs.readFileSync(regularFile(root, `${galleryRoot}/App/Shared/Flows/${file}`), "utf8")).join("\n");
  for (const id of expectedIDs) assert(registry.includes(`id: "${id}"`), `typed registry missing '${id}'`);
  for (const stateID of stateIDs) assert(registry.includes(`id: "${stateID}"`), `typed registry missing state '${stateID}'`);
  for (const view of stateViews) assert(registry.includes(`view: "${view}"`), `typed registry missing view '${view}'`);

  console.log(`Local demo catalog passed: ${ids.length} demos, ${stateIDs.length} states, ${assetNames.size} generated assets.`);
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exit(1);
}
