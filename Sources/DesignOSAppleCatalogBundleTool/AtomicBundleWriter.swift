import Darwin
import Foundation

enum AtomicBundleWriter {
  static func write(
    _ bytes: Data,
    parentDirectory: Int32,
    finalName: String,
    beforeRename: (() throws -> Void)? = nil
  ) throws {
    try requireRegularOrAbsent(finalName, in: parentDirectory)
    let temporary = ".\(finalName).\(UUID().uuidString).tmp"
    var shouldCleanTemporary = true
    defer {
      if shouldCleanTemporary { _ = unlinkat(parentDirectory, temporary, 0) }
    }
    let descriptor = openat(
      parentDirectory, temporary, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW, S_IRUSR | S_IWUSR)
    guard descriptor >= 0 else { throw fileError() }
    let handle = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
    try handle.write(contentsOf: bytes)
    try handle.synchronize()
    try handle.close()
    try beforeRename?()
    guard renameat(parentDirectory, temporary, parentDirectory, finalName) == 0 else {
      throw fileError()
    }
    shouldCleanTemporary = false
    guard fsync(parentDirectory) == 0 else { throw fileError() }
  }

  private static func requireRegularOrAbsent(_ name: String, in directory: Int32) throws {
    var metadata = stat()
    let result = fstatat(directory, name, &metadata, AT_SYMLINK_NOFOLLOW)
    if result == 0 {
      guard (metadata.st_mode & S_IFMT) == S_IFREG else { throw BundleCommand.ToolError.file }
    } else if errno != ENOENT {
      throw fileError()
    }
  }

  private static func fileError() -> BundleCommand.ToolError { .file }
}
