import Darwin
import DesignOSAppleCatalog
import Foundation

enum BundleCommand {
  static func run(
    arguments: [String],
    currentDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  ) throws {
    guard arguments.count == 3 else { throw ToolError.argument }
    let command = arguments[0]
    let option = arguments[1]
    let path = arguments[2]
    guard path == DesignOSStoryCatalogBundle.allowedRelativePath else { throw ToolError.path }

    switch (command, option) {
    case ("generate", "--bundle-output"):
      try withParentDirectory(at: currentDirectory) { directory in
        try AtomicBundleWriter.write(
          try DesignOSStoryCatalogBundle.encoded(), parentDirectory: directory, finalName: finalName
        )
      }
    case ("check", "--bundle-input"):
      do {
        try withParentDirectory(at: currentDirectory) { directory in
          _ = try DesignOSStoryCatalogBundle.validatedExpectedBytes(
            from: readRegularFile(in: directory))
        }
      } catch {
        throw ToolError.file
      }
    default:
      throw ToolError.argument
    }
  }

  private static let parentComponents = ["Examples", "DesignOSAppleGallery", "Generated"]
  private static let finalName = "design-os-apple-catalog-bundle.v2.json"

  private static func withParentDirectory<Value>(
    at root: URL, _ body: (Int32) throws -> Value
  ) throws -> Value {
    var directory = open(root.path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
    guard directory >= 0 else { throw ToolError.file }
    defer { close(directory) }
    for component in parentComponents {
      let next = openat(directory, component, O_RDONLY | O_DIRECTORY | O_NOFOLLOW)
      guard next >= 0 else { throw ToolError.file }
      close(directory)
      directory = next
    }
    return try body(directory)
  }

  private static func readRegularFile(in directory: Int32) throws -> Data {
    let descriptor = openat(directory, finalName, O_RDONLY | O_NOFOLLOW)
    guard descriptor >= 0 else { throw ToolError.file }
    var metadata = stat()
    guard fstat(descriptor, &metadata) == 0, (metadata.st_mode & S_IFMT) == S_IFREG else {
      close(descriptor)
      throw ToolError.file
    }
    let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
    return try handle.readToEnd() ?? Data()
  }

  enum ToolError: String, Error {
    case argument = "E_BUNDLE_ARGUMENT"
    case path = "E_BUNDLE_PATH"
    case file = "E_BUNDLE_FILE"
  }
}
