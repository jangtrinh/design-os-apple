import Foundation

do {
  try BundleCommand.run(arguments: Array(CommandLine.arguments.dropFirst()))
} catch let error as BundleCommand.ToolError {
  FileHandle.standardError.write(Data("\(error.rawValue)\n".utf8))
  exit(EXIT_FAILURE)
} catch {
  FileHandle.standardError.write(Data("E_BUNDLE_FILE\n".utf8))
  exit(EXIT_FAILURE)
}
