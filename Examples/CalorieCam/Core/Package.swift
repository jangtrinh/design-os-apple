// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "CalorieCamCore",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [.library(name: "CalorieCamCore", targets: ["CalorieCamCore"])],
  targets: [
    .target(name: "CalorieCamCore"),
    .testTarget(name: "CalorieCamCoreTests", dependencies: ["CalorieCamCore"]),
  ]
)
