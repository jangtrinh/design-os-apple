#!/usr/bin/env node
// Portable negative controls run by default. Native package controls are mandatory
// in test-publication-boundary.sh and must never silently fall back to portable mode.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const verifier = path.join(root, "scripts/verify-caloriecam-sample-provenance.mjs");
const resources = "Examples/CalorieCam/Resources";
const image = `${resources}/DemoMeal.png`;
const manifest = `${resources}/sample-image-provenance.v1.json`;
const provenance = `${resources}/provenance.md`;
const native = process.argv.includes("--with-package-tests");
assert(process.argv.length === (native ? 3 : 2), "usage: test-caloriecam-sample-provenance.mjs [--with-package-tests]");
const temporaryRoot = fs.mkdtempSync(path.join(fs.realpathSync(os.tmpdir()), "caloriecam-sample-test."));
let count = 0;

function run(caseRoot, assetsOnly = true) {
  const result = spawnSync(process.execPath, [verifier, "--root", caseRoot, ...(assetsOnly ? ["--assets-only"] : [])],
    { encoding: "utf8", timeout: assetsOnly ? 15_000 : 90_000, maxBuffer: 2 * 1024 * 1024 });
  assert.ifError(result.error);
  return { status: result.status, output: `${result.stdout}${result.stderr}` };
}
function accepted(label, caseRoot, assetsOnly = true) {
  const result = run(caseRoot, assetsOnly);
  assert.equal(result.status, 0, `${label}: ${result.output}`);
  assert.match(result.output, assetsOnly ? /Swift package isolation NOT VERIFIED/ : /Swift packages isolated/);
  count++;
}
function rejected(label, caseRoot, reason, assetsOnly = true) {
  const result = run(caseRoot, assetsOnly);
  assert.equal(result.status, 1, `${label} was not rejected: ${result.output}`);
  assert(result.output.includes(reason), `${label}: expected '${reason}', got '${result.output}'`);
  count++;
}
function fixture(label) {
  const destination = path.join(temporaryRoot, label);
  fs.mkdirSync(destination);
  for (const relative of [image, manifest, provenance, "Package.swift", "Examples/CalorieCam/Core/Package.swift"]) {
    fs.mkdirSync(path.dirname(path.join(destination, relative)), { recursive: true });
    fs.copyFileSync(path.join(root, relative), path.join(destination, relative));
  }
  return destination;
}
function mutateManifest(caseRoot, mutation) {
  const absolute = path.join(caseRoot, manifest);
  const value = JSON.parse(fs.readFileSync(absolute, "utf8"));
  mutation(value);
  fs.writeFileSync(absolute, `${JSON.stringify(value, null, 2)}\n`);
}
function crc32(bytes) {
  let crc = 0xffffffff;
  for (const byte of bytes) {
    crc ^= byte;
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ (0xedb88320 & -(crc & 1));
  }
  return (crc ^ 0xffffffff) >>> 0;
}
function mutateChunk(caseRoot, type, mutation) {
  const absolute = path.join(caseRoot, image), bytes = fs.readFileSync(absolute);
  let offset = 8;
  while (offset < bytes.length) {
    const size = bytes.readUInt32BE(offset), end = offset + 12 + size;
    if (bytes.toString("ascii", offset + 4, offset + 8) === type) {
      mutation(bytes.subarray(offset + 8, end - 4));
      bytes.writeUInt32BE(crc32(bytes.subarray(offset + 4, end - 4)), end - 4);
      fs.writeFileSync(absolute, bytes);
      return;
    }
    offset = end;
  }
  assert.fail(`missing test chunk ${type}`);
}

try {
  accepted("repository baseline", root);
  accepted("copied baseline", fixture("baseline"));
  for (const [label, relative] of [["missing-image", image], ["missing-manifest", manifest], ["missing-provenance", provenance]]) {
    const caseRoot = fixture(label);
    fs.unlinkSync(path.join(caseRoot, relative));
    rejected(label, caseRoot, `missing file '${relative}'`);
  }
  for (const [label, mutation, reason] of [
    ["extra-manifest-asset", (m) => m.assets.push({ ...m.assets[0], name: "Extra" }), "manifest asset count mismatch"],
    ["wrong-path", (m) => { m.assets[0].path = `${resources}/Extra.png`; }, "source-bound sample declaration"],
    ["stale-hash", (m) => { m.assets[0].sha256 = "0".repeat(64); }, "source-bound sample declaration"],
    ["size-rebinding", (m) => { m.assets[0].byteSize++; }, "source-bound sample declaration"],
    ["dimensions-rebinding", (m) => { m.assets[0].dimensions.width = 2048; }, "source-bound sample declaration"],
    ["wrong-mime", (m) => { m.assets[0].mimeType = "image/jpeg"; }, "source-bound sample declaration"],
    ["missing-synthetic-declaration", (m) => { delete m.assets[0].synthetic; }, "source-bound sample declaration"],
    ["false-nutrition-claim", (m) => { m.assets[0].nutritionalGroundTruth = true; }, "source-bound sample declaration"],
    ["extra-manifest-field", (m) => { m.unreviewed = true; }, "unexpected manifest fields"],
  ]) {
    const caseRoot = fixture(label);
    mutateManifest(caseRoot, mutation);
    rejected(label, caseRoot, reason);
  }
  let caseRoot = fixture("corrupted-image");
  let bytes = fs.readFileSync(path.join(caseRoot, image));
  bytes[100] ^= 1;
  fs.writeFileSync(path.join(caseRoot, image), bytes);
  rejected("corrupted image", caseRoot, "PNG CRC mismatch");

  caseRoot = fixture("corrupt-signature");
  bytes = fs.readFileSync(path.join(caseRoot, image));
  bytes[0] = 0;
  fs.writeFileSync(path.join(caseRoot, image), bytes);
  rejected("corrupted signature", caseRoot, "invalid PNG signature");

  caseRoot = fixture("truncated-image");
  fs.truncateSync(path.join(caseRoot, image), 33);
  rejected("truncated image", caseRoot, "sample byte size mismatch");

  caseRoot = fixture("changed-dimensions");
  mutateChunk(caseRoot, "IHDR", (data) => data.writeUInt32BE(2048, 0));
  rejected("changed dimensions with valid CRC", caseRoot, "PNG dimensions mismatch");

  caseRoot = fixture("undecodable-png");
  mutateChunk(caseRoot, "IDAT", (data) => { data[0] = 0; data[1] = 0; });
  rejected("undecodable PNG with valid CRC", caseRoot, "PNG decode failed");

  caseRoot = fixture("changed-valid-image");
  mutateChunk(caseRoot, "caBX", (data) => { data[0] ^= 1; });
  rejected("changed valid image", caseRoot, "sample SHA-256 mismatch");
  mutateManifest(caseRoot, (m) => {
    m.assets[0].sha256 = crypto.createHash("sha256").update(fs.readFileSync(path.join(caseRoot, image))).digest("hex");
  });
  rejected("changed image and rebound manifest", caseRoot, "source-bound sample declaration");

  caseRoot = fixture("changed-provenance");
  fs.appendFileSync(path.join(caseRoot, provenance), "\nUnreviewed provenance change.\n");
  rejected("changed provenance", caseRoot, "sample provenance SHA-256 mismatch");
  mutateManifest(caseRoot, (m) => {
    m.assets[0].provenance.sha256 = crypto.createHash("sha256").update(fs.readFileSync(path.join(caseRoot, provenance))).digest("hex");
  });
  rejected("changed provenance and rebound manifest", caseRoot, "source-bound sample declaration");

  for (const name of ["Extra.png", "Extra.dat"]) {
    caseRoot = fixture(`unapproved-${name}`);
    fs.copyFileSync(path.join(caseRoot, image), path.join(caseRoot, resources, name));
    rejected(`unapproved extra ${name}`, caseRoot, "sample resource inventory mismatch");
  }
  caseRoot = fixture("extra-directory");
  fs.mkdirSync(path.join(caseRoot, resources, "unapproved"));
  rejected("unapproved resource directory", caseRoot, "sample resource inventory mismatch");

  for (const [label, relative] of [["image-symlink", image], ["manifest-symlink", manifest], ["provenance-symlink", provenance]]) {
    caseRoot = fixture(label);
    fs.unlinkSync(path.join(caseRoot, relative));
    fs.symlinkSync(path.join(root, relative), path.join(caseRoot, relative));
    rejected(label, caseRoot, "nonregular or symlinked");
  }
  caseRoot = fixture("parent-symlink");
  fs.renameSync(path.join(caseRoot, resources), path.join(caseRoot, "moved-resources"));
  fs.symlinkSync(path.join(caseRoot, "moved-resources"), path.join(caseRoot, resources));
  rejected("symlinked parent directory", caseRoot, "symlink-resolved");

  if (native) {
    accepted("native repository baseline", root, false);
    for (const [label, packagePath, target, rule, resource] of [
      ["package-image-copy", "Package.swift", "DesignOSApple", "copy", `../../${image}`],
      ["package-resource-process", "Package.swift", "DesignOSApple", "process", `../../${resources}`],
      ["package-parent-copy", "Package.swift", "DesignOSApple", "copy", "../../Examples/CalorieCam"],
      ["core-resource-copy", "Examples/CalorieCam/Core/Package.swift", "CalorieCamCore", "copy", "../../../Resources"],
    ]) {
      caseRoot = fixture(label);
      const file = path.join(caseRoot, packagePath);
      const original = fs.readFileSync(file, "utf8");
      const changed = original.replace(`.target(name: "${target}"),`,
        `.target(name: "${target}", resources: [.${rule}("${resource}")]),`);
      assert.notEqual(changed, original, `${label}: package fixture was not mutated`);
      fs.writeFileSync(file, changed);
      rejected(label, caseRoot, "Swift package admits CalorieCam sample", false);
    }
    caseRoot = fixture("missing-core-package");
    fs.unlinkSync(path.join(caseRoot, "Examples/CalorieCam/Core/Package.swift"));
    rejected("missing Core package", caseRoot, "missing file 'Examples/CalorieCam/Core/Package.swift'", false);
  }
  console.log(`CalorieCam sample hostile probes passed: ${count} checks; ${native ? "native package controls included" : "Swift package isolation NOT VERIFIED"}.`);
} finally {
  fs.rmSync(temporaryRoot, { recursive: true, force: true });
}
