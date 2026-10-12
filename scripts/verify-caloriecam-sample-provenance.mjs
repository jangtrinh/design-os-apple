#!/usr/bin/env node
// This is one reviewed sample fixture, not a general image admission mechanism.
// Both the source constants and the manifest must change to review a replacement.
import { spawnSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { isDeepStrictEqual } from "node:util";
import { inflateSync } from "node:zlib";

const resourceRoot = "Examples/CalorieCam/Resources";
const manifestPath = `${resourceRoot}/sample-image-provenance.v1.json`;
const expectedAsset = {
  name: "DemoMeal",
  path: `${resourceRoot}/DemoMeal.png`,
  byteSize: 2616037,
  sha256: "46b0bd52d774aae7490e8efe3ac85a630b0fb17efe013dceae63f81cb75f9c22",
  mimeType: "image/png",
  dimensions: { width: 1254, height: 1254 },
  generator: "built-in OpenAI image generation tool, original generation",
  created: "2026-10-10",
  intendedUse: "CalorieCam-only labeled offline sample meal and native UI tests",
  synthetic: true,
  originalBytesUnchanged: true,
  nutritionalGroundTruth: false,
  modelAccuracyEvidence: false,
  provenance: {
    path: `${resourceRoot}/provenance.md`,
    sha256: "8ce4494a43a19e31a9af6a5a64db4642868841a9bc017c3d795665a09cd3ba0f",
  },
};
const pngSignature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const fail = (message) => { throw new Error(`E_CALORIECAM_SAMPLE: ${message}`); };
const assert = (condition, message) => { if (!condition) fail(message); };
const sha256 = (bytes) => crypto.createHash("sha256").update(bytes).digest("hex");

function regularFile(root, relative) {
  const absolute = path.join(root, relative);
  let metadata;
  try { metadata = fs.lstatSync(absolute); }
  catch (error) {
    if (error.code === "ENOENT") fail(`missing file '${relative}'`);
    fail(`cannot inspect '${relative}': ${error.message}`);
  }
  assert(metadata.isFile() && !metadata.isSymbolicLink(), `nonregular or symlinked '${relative}'`);
  assert(fs.realpathSync(absolute) === absolute, `symlink-resolved '${relative}'`);
  return { absolute, metadata };
}

function verifyResourceInventory(root) {
  const absolute = path.join(root, resourceRoot);
  assert(fs.realpathSync(absolute) === absolute, `symlink-resolved '${resourceRoot}'`);
  const expected = [path.basename(expectedAsset.path), path.basename(expectedAsset.provenance.path),
    path.basename(manifestPath)].sort();
  assert(isDeepStrictEqual(fs.readdirSync(absolute).sort(), expected),
    "sample resource inventory mismatch; only the one reviewed asset and its provenance are admitted");
}

function crc32(bytes) {
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return (crc ^ 0xffffffff) >>> 0;
}

function verifyPNG(bytes) {
  assert(bytes.length >= 33 && bytes.subarray(0, 8).equals(pngSignature), "invalid PNG signature");
  const idat = [];
  let offset = 8, sawHeader = false, sawEnd = false, endedData = false;
  while (offset < bytes.length) {
    assert(offset + 12 <= bytes.length, "truncated PNG chunk");
    const size = bytes.readUInt32BE(offset), end = offset + size + 12;
    assert(end <= bytes.length, "truncated PNG chunk");
    const type = bytes.toString("ascii", offset + 4, offset + 8);
    assert(/^[A-Za-z]{4}$/.test(type), "invalid PNG chunk type");
    assert(bytes.readUInt32BE(end - 4) === crc32(bytes.subarray(offset + 4, end - 4)),
      `PNG CRC mismatch in '${type}'`);
    const data = bytes.subarray(offset + 8, end - 4);
    if (!sawHeader) assert(type === "IHDR" && size === 13, "invalid first PNG IHDR");
    if (type === "IHDR") {
      assert(!sawHeader && offset === 8 && size === 13, "invalid PNG IHDR");
      assert(data.readUInt32BE(0) === expectedAsset.dimensions.width &&
        data.readUInt32BE(4) === expectedAsset.dimensions.height, "PNG dimensions mismatch");
      assert(data[8] === 8 && data[9] === 2 && data[10] === 0 && data[11] === 0 && data[12] === 0,
        "PNG must be non-interlaced 8-bit RGB");
      sawHeader = true;
    } else if (type === "IDAT") {
      assert(!endedData, "nonconsecutive PNG IDAT");
      idat.push(data);
    } else {
      if (idat.length) endedData = true;
      if (type === "IEND") {
        assert(size === 0 && end === bytes.length, "invalid terminal PNG IEND");
        sawEnd = true;
      } else {
        assert(type[0] === type[0].toLowerCase() || type === "PLTE", `unknown critical PNG chunk '${type}'`);
      }
    }
    offset = end;
  }
  assert(idat.length > 0 && sawEnd, "missing PNG IDAT or terminal IEND");
  const stride = expectedAsset.dimensions.width * 3 + 1;
  const decodedSize = stride * expectedAsset.dimensions.height;
  let decoded;
  try { decoded = inflateSync(Buffer.concat(idat), { maxOutputLength: decodedSize }); }
  catch (error) { fail(`PNG decode failed: ${error.message}`); }
  assert(decoded.length === decodedSize, "PNG decoded byte size mismatch");
  for (let offset = 0; offset < decoded.length; offset += stride) {
    assert(decoded[offset] <= 4, "invalid PNG row filter");
  }
}

function verifyAssets(root) {
  const manifestFile = regularFile(root, manifestPath);
  assert(manifestFile.metadata.size <= 16 * 1024, "sample manifest exceeds 16 KiB");
  let manifest;
  try { manifest = JSON.parse(fs.readFileSync(manifestFile.absolute, "utf8")); }
  catch (error) { fail(`invalid manifest JSON: ${error.message}`); }
  assert(manifest.schemaVersion === 1 && manifest.artifactClass === "caloriecam-synthetic-sample",
    "manifest schema or class mismatch");
  assert(Array.isArray(manifest.assets) && manifest.assets.length === 1, "manifest asset count mismatch");
  assert(isDeepStrictEqual(Object.keys(manifest).sort(), ["artifactClass", "assets", "schemaVersion"]),
    "unexpected manifest fields");
  assert(isDeepStrictEqual(manifest.assets[0], expectedAsset), "manifest differs from source-bound sample declaration");
  const { absolute, metadata } = regularFile(root, expectedAsset.path);
  assert(metadata.size === expectedAsset.byteSize, "sample byte size mismatch");
  const bytes = fs.readFileSync(absolute);
  verifyPNG(bytes);
  const mime = spawnSync("file", ["-b", "--mime-type", absolute], { encoding: "utf8", timeout: 10_000 });
  assert(!mime.error && mime.status === 0, "sample MIME inspection could not run");
  assert(mime.stdout.trim() === expectedAsset.mimeType, "sample MIME mismatch");
  assert(sha256(bytes) === expectedAsset.sha256, "sample SHA-256 mismatch");
  const provenance = regularFile(root, expectedAsset.provenance.path);
  assert(provenance.metadata.size <= 16 * 1024, "sample provenance exceeds 16 KiB");
  assert(sha256(fs.readFileSync(provenance.absolute)) === expectedAsset.provenance.sha256,
    "sample provenance SHA-256 mismatch");
  verifyResourceInventory(root);
}

function overlaps(first, second) {
  return first === second || first.startsWith(`${second}${path.sep}`) || second.startsWith(`${first}${path.sep}`);
}

function verifyPackageBoundary(root) {
  const forbidden = path.resolve(root, resourceRoot);
  for (const packageRelative of [".", "Examples/CalorieCam/Core"]) {
    const packageRoot = path.resolve(root, packageRelative);
    regularFile(root, path.join(packageRelative, "Package.swift"));
    const result = spawnSync("/usr/bin/swift", ["package", "dump-package", "--package-path", packageRoot],
      { encoding: "utf8", timeout: 30_000, maxBuffer: 4 * 1024 * 1024 });
    assert(!result.error, `Swift package inspection could not run: ${result.error?.message}`);
    assert(result.status === 0, `Swift package inspection failed: ${(result.stderr || "no diagnostic").trim()}`);
    let declared;
    try { declared = JSON.parse(result.stdout); }
    catch (error) { fail(`Swift package inspection returned invalid JSON: ${error.message}`); }
    assert(Array.isArray(declared.targets), "Swift package inspection lacks targets");
    for (const target of declared.targets) {
      const defaultRoot = target.type === "test" ? `Tests/${target.name}` : `Sources/${target.name}`;
      const targetRoot = path.resolve(packageRoot, target.path ?? defaultRoot);
      for (const resource of target.resources ?? []) {
        const resourcePath = path.resolve(targetRoot, resource.path);
        assert(resourcePath === root || resourcePath.startsWith(`${root}${path.sep}`),
          `Swift package target '${target.name}' has out-of-root resource '${resource.path}'`);
        let resolved = resourcePath;
        try { resolved = fs.realpathSync(resourcePath); }
        catch (error) { if (error.code !== "ENOENT") fail(`cannot resolve package resource: ${error.message}`); }
        assert(!overlaps(resolved, forbidden),
          `Swift package admits CalorieCam sample through target '${target.name}' resource '${resource.path}'`);
      }
    }
  }
}

function main() {
  const args = process.argv.slice(2);
  assert((args.length === 2 || (args.length === 3 && args[2] === "--assets-only")) && args[0] === "--root",
    "usage: verify-caloriecam-sample-provenance.mjs --root <project-root> [--assets-only]");
  const root = fs.realpathSync(path.resolve(args[1]));
  assert(fs.statSync(root).isDirectory(), "project root is not a directory");
  verifyAssets(root);
  if (args[2] === "--assets-only") {
    console.log("CalorieCam sample asset/provenance checks passed: 1 source-bound fixture; Swift package isolation NOT VERIFIED.");
    return;
  }
  verifyPackageBoundary(root);
  console.log(`CalorieCam sample admission passed: 1 source-bound fixture, ${expectedAsset.byteSize} bytes, Swift packages isolated.`);
}

try { main(); }
catch (error) { console.error(error.message); process.exit(1); }
