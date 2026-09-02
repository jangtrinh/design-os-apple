import Darwin
import Foundation
import Testing

@testable import DesignOSAppleCatalogBundleTool

@Test("Bundle lifecycle generates atomically and checks without writing")
func bundleLifecycleGeneratesAndChecks() throws {
  let root = try temporaryRoot()
  defer { try? FileManager.default.removeItem(at: root) }
  let bundle = root.appendingPathComponent(
    "Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json")
  try FileManager.default.createDirectory(
    at: bundle.deletingLastPathComponent(), withIntermediateDirectories: true)

  try BundleCommand.run(
    arguments: ["generate", "--bundle-output", allowedPath], currentDirectory: root)
  let generated = try Data(contentsOf: bundle)
  try BundleCommand.run(
    arguments: ["check", "--bundle-input", allowedPath], currentDirectory: root)
  #expect(try Data(contentsOf: bundle) == generated)

  try BundleCommand.run(
    arguments: ["generate", "--bundle-output", allowedPath], currentDirectory: root)
  #expect(try Data(contentsOf: bundle) == generated)

  let beforeFailingCheck = try Data(contentsOf: bundle)
  try Data("invalid".utf8).write(to: bundle)
  let invalidBeforeCheck = try Data(contentsOf: bundle)
  #expect(throws: BundleCommand.ToolError.file) {
    try BundleCommand.run(
      arguments: ["check", "--bundle-input", allowedPath], currentDirectory: root)
  }
  #expect(try Data(contentsOf: bundle) == invalidBeforeCheck)
  try beforeFailingCheck.write(to: bundle)
}

@Test("Bundle lifecycle rejects disallowed paths and nonregular output")
func bundleLifecycleRejectsUnsafePaths() throws {
  let root = try temporaryRoot()
  defer { try? FileManager.default.removeItem(at: root) }
  #expect(throws: BundleCommand.ToolError.path) {
    try BundleCommand.run(
      arguments: ["generate", "--bundle-output", "outside.json"], currentDirectory: root)
  }
  let bundle = root.appendingPathComponent(
    "Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json")
  try FileManager.default.createDirectory(at: bundle, withIntermediateDirectories: true)
  #expect(throws: BundleCommand.ToolError.file) {
    try BundleCommand.run(
      arguments: ["generate", "--bundle-output", allowedPath], currentDirectory: root)
  }
}

@Test("Pre-rename failure retains old bytes and cleans the temporary file")
func bundleLifecycleCleansPreRenameFailure() throws {
  let root = try temporaryRoot()
  defer { try? FileManager.default.removeItem(at: root) }
  let directory = root.appendingPathComponent("Generated")
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  let output = directory.appendingPathComponent("bundle.json")
  let oldBytes = Data("old".utf8)
  try oldBytes.write(to: output)
  let descriptor = open(directory.path, O_RDONLY | O_DIRECTORY)
  defer { close(descriptor) }
  #expect(throws: LifecycleFailure.self) {
    try AtomicBundleWriter.write(
      Data("new".utf8), parentDirectory: descriptor, finalName: "bundle.json"
    ) {
      throw LifecycleFailure.preRename
    }
  }
  #expect(try Data(contentsOf: output) == oldBytes)
  #expect(try FileManager.default.contentsOfDirectory(atPath: directory.path).count == 1)
}

@Test("Bundle lifecycle rejects a final symlink for generate and check")
func bundleLifecycleRejectsFinalSymlink() throws {
  let root = try temporaryRoot()
  defer { try? FileManager.default.removeItem(at: root) }
  let bundle = try bundleURL(in: root)
  let external = root.appendingPathComponent("external.json")
  try Data("external".utf8).write(to: external)
  try FileManager.default.createSymbolicLink(at: bundle, withDestinationURL: external)
  for command in ["generate", "check"] {
    #expect(throws: BundleCommand.ToolError.file) {
      try BundleCommand.run(
        arguments: [
          command, command == "generate" ? "--bundle-output" : "--bundle-input", allowedPath,
        ], currentDirectory: root)
    }
  }
}

@Test("Bundle lifecycle rejects a symlinked parent component")
func bundleLifecycleRejectsSymlinkedParent() throws {
  let root = try temporaryRoot()
  defer { try? FileManager.default.removeItem(at: root) }
  let outside = root.appendingPathComponent("outside")
  try FileManager.default.createDirectory(
    at: outside.appendingPathComponent("DesignOSAppleGallery/Generated"),
    withIntermediateDirectories: true
  )
  try FileManager.default.createSymbolicLink(
    at: root.appendingPathComponent("Examples"), withDestinationURL: outside)

  #expect(throws: BundleCommand.ToolError.file) {
    try BundleCommand.run(
      arguments: ["generate", "--bundle-output", allowedPath], currentDirectory: root)
  }
}

private let allowedPath =
  "Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json"

private func temporaryRoot() throws -> URL {
  let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
  return root
}

private func bundleURL(in root: URL) throws -> URL {
  let bundle = root.appendingPathComponent(
    "Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json")
  try FileManager.default.createDirectory(
    at: bundle.deletingLastPathComponent(), withIntermediateDirectories: true)
  return bundle
}

private enum LifecycleFailure: Error { case preRename }
