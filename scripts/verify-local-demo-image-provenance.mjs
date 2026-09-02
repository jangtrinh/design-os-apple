#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
const manifestPath = "Examples/DesignOSAppleGallery/Generated/local-demo-image-provenance.v1.json";
const catalogRoot = "Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets";
const mediaRoot = "Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets";
const generatedRoots = ["Examples/DesignOSAppleGallery/Generated", catalogRoot, mediaRoot];
const thumbnailNames = ["demo-thoughtful-chat-thumbnail", "demo-visual-assistant-thumbnail",
  "demo-flight-tracker-thumbnail", "demo-city-ride-thumbnail",
  "demo-streaming-library-thumbnail", "demo-song-finder-thumbnail"];
const expectedAssets = thumbnailNames.map((name) => ({
  name, path: `${catalogRoot}/${name}.imageset/${name}.png`, root: catalogRoot,
  intendedUse: "Gallery-only local-demo catalog thumbnail", aspect: [4, 3],
})).concat([
  { name: "visual-assistant-answer-art", root: mediaRoot,
    path: `${mediaRoot}/visual-assistant-answer-art.imageset/visual-assistant-answer-art.png`,
    intendedUse: "Gallery-only local-demo answer media", aspect: [4, 3] },
  { name: "streaming-library-poster-atlas", root: mediaRoot,
    path: `${mediaRoot}/streaming-library-poster-atlas.imageset/streaming-library-poster-atlas.png`,
    intendedUse: "Gallery-only local-demo streaming poster atlas", aspect: [1, 1] },
  { name: "song-finder-afterglow-cover", root: mediaRoot,
    path: `${mediaRoot}/song-finder-afterglow-cover.imageset/song-finder-afterglow-cover.png`,
    intendedUse: "Gallery-only local-demo song artwork", aspect: [2, 3] },
  { name: "city-ride-arrival-essentials", root: mediaRoot,
    path: `${mediaRoot}/city-ride-arrival-essentials.imageset/city-ride-arrival-essentials.png`,
    intendedUse: "Gallery-only local-demo city-ride arrival card media", aspect: [16, 9] },
]);
const cleanRoomDeclaration = { referencePixelsUsedAsInput: false, sourceScreenshotCommitted: false,
  containsLogoOrTrademark: false, containsReadableText: false, containsSignatureOrWatermark: false };
const pngSignature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
function fail(message) { throw new Error(`E_GALLERY_GENERATED_ART: ${message}`); }
function assert(condition, message) { if (!condition) fail(message); }
function canonicalRoot(argument) {
  let root;
  try { root = fs.realpathSync(path.resolve(argument)); }
  catch (error) { fail(`cannot resolve project root: ${error.message}`); }
  assert(fs.statSync(root).isDirectory(), "project root is not a directory");
  return root;
}
function regularFile(root, relativePath) {
  const absolutePath = path.join(root, relativePath);
  let metadata;
  try { metadata = fs.lstatSync(absolutePath); }
  catch (error) {
    if (error.code === "ENOENT") fail(`missing file '${relativePath}'`);
    fail(`cannot inspect '${relativePath}': ${error.message}`);
  }
  assert(metadata.isFile() && !metadata.isSymbolicLink(), `nonregular or symlinked '${relativePath}'`);
  assert(fs.realpathSync(absolutePath) === absolutePath, `symlink-resolved '${relativePath}'`);
  return { absolutePath, metadata };
}
function readJSON(root, relativePath) {
  const { absolutePath } = regularFile(root, relativePath);
  try { return JSON.parse(fs.readFileSync(absolutePath, "utf8")); }
  catch (error) { fail(`invalid JSON '${relativePath}': ${error.message}`); }
}
function targetBlock(project, targetName) {
  const escaped = targetName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const match = project.match(new RegExp(`^  ${escaped}:\\n([\\s\\S]*?)(?=^  [A-Za-z0-9][^\\n]*:\\n|(?![\\s\\S]))`, "m"));
  assert(match, `missing Gallery target '${targetName}'`);
  return match[1];
}
function pathsOverlap(first, second) {
  return first === second || first.startsWith(`${second}${path.sep}`) || second.startsWith(`${first}${path.sep}`);
}
function semanticPackage(root) {
  const result = spawnSync("/usr/bin/swift", ["package", "dump-package", "--package-path", root], {
    encoding: "utf8", timeout: 30_000, maxBuffer: 4 * 1024 * 1024,
  });
  assert(!result.error, `Swift package inspection could not run: ${result.error?.message}`);
  assert(result.status === 0, `Swift package inspection failed: ${(result.stderr || "no diagnostic").trim()}`);
  try { return JSON.parse(result.stdout); }
  catch (error) { fail(`Swift package inspection returned invalid JSON: ${error.message}`); }
}
function verifyPackageBoundary(root) {
  const forbidden = generatedRoots.map((relative) => path.resolve(root, relative));
  for (const target of semanticPackage(root).targets ?? []) {
    const defaultRoot = target.type === "test" ? `Tests/${target.name}` : `Sources/${target.name}`;
    const targetRoot = path.resolve(root, target.path ?? defaultRoot);
    for (const resource of target.resources ?? []) {
      const resourcePath = path.resolve(targetRoot, resource.path);
      assert(resourcePath === root || resourcePath.startsWith(`${root}${path.sep}`),
        `Swift package target '${target.name}' has out-of-root resource '${resource.path}'`);
      let resolvedPath = resourcePath;
      try { resolvedPath = fs.realpathSync(resourcePath); }
      catch (error) { if (error.code !== "ENOENT") fail(`cannot resolve Swift package resource '${resource.path}': ${error.message}`); }
      assert(!forbidden.some((forbiddenPath) => pathsOverlap(resolvedPath, forbiddenPath)),
        `Swift package admits Gallery generated art through target '${target.name}' resource '${resource.path}'`);
    }
  }
}
function verifyProjectBoundary(root) {
  const projectRelative = "Examples/DesignOSAppleGallery/project.yml";
  const { absolutePath } = regularFile(root, projectRelative);
  const project = fs.readFileSync(absolutePath, "utf8");
  const memberships = [catalogRoot, mediaRoot].map((assetPath) =>
    `- path: ${assetPath.replace("Examples/DesignOSAppleGallery/", "")}\n        buildPhase: resources`);
  for (const target of ["DesignOSAppleGallery-iOS", "DesignOSAppleGallery-macOS"]) {
    for (const membership of memberships) {
      assert(targetBlock(project, target).includes(membership), `${target} lacks Gallery resource membership`);
    }
  }
  verifyPackageBoundary(root);
  const forbiddenNames = expectedAssets.map(({ name }) => name).concat("local-demo-image-provenance");
  const runtimeRoot = path.join(root, "Sources/DesignOSApple");
  const pending = fs.existsSync(runtimeRoot) ? [runtimeRoot] : [];
  while (pending.length > 0) {
    const entry = pending.pop();
    for (const child of fs.readdirSync(entry, { withFileTypes: true })) {
      const childPath = path.join(entry, child.name);
      if (child.isDirectory()) pending.push(childPath);
      if (child.isFile()) assert(!forbiddenNames.some((name) => fs.readFileSync(childPath, "utf8").includes(name)),
        "runtime references Gallery generated art");
    }
  }
}
function verifyContents(root, asset) {
  const contents = readJSON(root, `${asset.root}/${asset.name}.imageset/Contents.json`);
  const expected = {
    images: [
      { filename: `${asset.name}.png`, idiom: "universal", scale: "1x" },
      { idiom: "universal", scale: "2x" },
      { idiom: "universal", scale: "3x" },
    ],
    info: { author: "xcode", version: 1 },
  };
  assert(JSON.stringify(contents) === JSON.stringify(expected), `Contents mismatch for '${asset.name}'`);
}
function crc32(buffers) {
  let crc = 0xffffffff;
  for (const buffer of buffers) for (const byte of buffer) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit += 1) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return (crc ^ 0xffffffff) >>> 0;
}
function inspectPNG(buffer, relativePath) {
  assert(buffer.length >= 33 && buffer.subarray(0, 8).equals(pngSignature), `invalid PNG signature '${relativePath}'`);
  let offset = 8, first = true, sawIHDR = false, sawIDAT = false, sawIEND = false, dimensions;
  while (offset < buffer.length) {
    assert(offset + 12 <= buffer.length, `truncated PNG chunk '${relativePath}'`);
    const length = buffer.readUInt32BE(offset);
    const type = buffer.toString("ascii", offset + 4, offset + 8);
    assert(/^[A-Za-z]{4}$/.test(type), `invalid PNG chunk type '${relativePath}'`);
    const end = offset + 12 + length;
    assert(end <= buffer.length, `truncated PNG chunk '${relativePath}'`);
    const typeBytes = buffer.subarray(offset + 4, offset + 8), data = buffer.subarray(offset + 8, offset + 8 + length);
    assert(buffer.readUInt32BE(offset + 8 + length) === crc32([typeBytes, data]), `PNG CRC mismatch '${relativePath}' chunk '${type}'`);
    if (first) assert(type === "IHDR" && length === 13, `invalid PNG IHDR '${relativePath}'`);
    if (type === "IHDR") {
      assert(!sawIHDR && first && length === 13, `invalid PNG IHDR '${relativePath}'`);
      sawIHDR = true; dimensions = { width: data.readUInt32BE(0), height: data.readUInt32BE(4) };
    }
    if (type === "IDAT") sawIDAT = true;
    if (type === "IEND") {
      assert(length === 0 && end === buffer.length, `invalid terminal PNG IEND '${relativePath}'`);
      sawIEND = true;
    }
    offset = end; first = false;
    if (sawIEND) break;
  }
  assert(sawIHDR, `missing PNG IHDR '${relativePath}'`);
  assert(sawIDAT, `missing PNG IDAT '${relativePath}'`);
  assert(sawIEND, `missing terminal PNG IEND '${relativePath}'`);
  return dimensions;
}
function verifyHostDecode(absolutePath, relativePath) {
  const decoder = "/usr/bin/sips";
  if (!fs.existsSync(decoder)) return;
  const temporaryRoot = fs.mkdtempSync(path.join(fs.realpathSync(os.tmpdir()), "design-os-apple-png-decode."));
  try {
    const result = spawnSync(decoder, ["-s", "format", "png", absolutePath, "--out", path.join(temporaryRoot, "decoded.png")],
      { encoding: "utf8", timeout: 30_000, maxBuffer: 1024 * 1024 });
    assert(!result.error && result.status === 0, `host PNG decode failed '${relativePath}'`);
  } finally { fs.rmSync(temporaryRoot, { recursive: true }); }
}
function verifyAsset(root, declared, expected) {
  assert(declared && typeof declared === "object" && !Array.isArray(declared), `malformed asset '${expected.name}'`);
  assert(declared.name === expected.name && declared.path === expected.path, `identity mismatch for '${expected.name}'`);
  assert(declared.mimeType === "image/png", `MIME mismatch for '${expected.name}'`);
  assert(declared.intendedUse === expected.intendedUse, `intended use mismatch for '${expected.name}'`);
  assert(declared.generator === "OpenAI Codex GPT Image 2", `generator mismatch for '${expected.name}'`);
  assert(JSON.stringify(declared.cleanRoom) === JSON.stringify(cleanRoomDeclaration), `clean-room declaration mismatch for '${expected.name}'`);
  assert(declared.reviewDisposition === "accepted-for-local-integration", `review disposition mismatch for '${expected.name}'`);
  assert(typeof declared.prompt === "string" && declared.prompt.length > 0, `missing generation prompt for '${expected.name}'`);
  assert(typeof declared.reviewNote === "string" && declared.reviewNote.length > 0, `missing review note for '${expected.name}'`);
  const { absolutePath, metadata } = regularFile(root, expected.path);
  assert(metadata.size <= 3 * 1024 * 1024, `file exceeds 3 MiB '${expected.path}'`);
  assert(declared.byteSize === metadata.size, `byte size mismatch for '${expected.name}'`);
  const buffer = fs.readFileSync(absolutePath), dimensions = inspectPNG(buffer, expected.path);
  assert(dimensions.width > 0 && dimensions.height > 0, `invalid dimensions for '${expected.name}'`);
  assert(dimensions.width <= 2048 && dimensions.height <= 2048, `dimension exceeds 2048 for '${expected.name}'`);
  assert(dimensions.width * dimensions.height <= 4_000_000, `pixel count exceeds 4 MP for '${expected.name}'`);
  assert(JSON.stringify(declared.dimensions) === JSON.stringify(dimensions), `dimension declaration mismatch for '${expected.name}'`);
  assert(dimensions.width * expected.aspect[1] === dimensions.height * expected.aspect[0],
    `aspect ratio mismatch for '${expected.name}'`);
  const hash = crypto.createHash("sha256").update(buffer).digest("hex");
  assert(/^[a-f0-9]{64}$/.test(declared.sha256) && declared.sha256 === hash, `SHA-256 mismatch for '${expected.name}'`);
  verifyHostDecode(absolutePath, expected.path); verifyContents(root, expected);
  return metadata.size;
}
function main() {
  assert(process.argv.length === 4 && process.argv[2] === "--root", "usage: verify-local-demo-image-provenance.mjs --root <project-root>");
  const root = canonicalRoot(process.argv[3]), manifest = readJSON(root, manifestPath);
  assert(manifest.schemaVersion === 1 && manifest.artifactClass === "gallery-generated-art", "manifest schema or class mismatch");
  assert(Array.isArray(manifest.assets) && manifest.assets.length === expectedAssets.length, "manifest asset count mismatch");
  const names = manifest.assets.map((asset) => asset?.name), paths = manifest.assets.map((asset) => asset?.path);
  assert(new Set(names).size === names.length && new Set(paths).size === paths.length, "duplicate manifest identity");
  assert([...names].sort().join("\n") === expectedAssets.map(({ name }) => name).sort().join("\n"), "manifest name set mismatch");
  assert([...paths].sort().join("\n") === expectedAssets.map((asset) => asset.path).sort().join("\n"), "manifest path set mismatch");
  const byPath = new Map(manifest.assets.map((asset) => [asset.path, asset]));
  const aggregate = expectedAssets.reduce((total, asset) => total + verifyAsset(root, byPath.get(asset.path), asset), 0);
  assert(aggregate <= 20 * 1024 * 1024, "aggregate generated art exceeds 20 MiB");
  verifyProjectBoundary(root);
  console.log(`Gallery generated art passed: ${expectedAssets.length} fixed assets, ${aggregate} bytes.`);
}
try { main(); }
catch (error) { console.error(error.message); process.exit(1); }
