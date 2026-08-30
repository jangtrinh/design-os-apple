// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DesignOSApple",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "DesignOSApple",
            targets: ["DesignOSApple"]
        ),
        .library(
            name: "DesignOSAppleExtensions",
            targets: ["DesignOSAppleExtensions"]
        ),
        .library(
            name: "DesignOSAppleCatalog",
            targets: ["DesignOSAppleCatalog"]
        ),
        .executable(
            name: "DesignOSAppleCatalogBundleTool",
            targets: ["DesignOSAppleCatalogBundleTool"]
        ),
    ],
    targets: [
        .target(name: "DesignOSApple"),
        .target(
            name: "DesignOSAppleExtensions",
            dependencies: ["DesignOSApple"],
            path: "Extensions/DesignOSAppleExtensions"
        ),
        .target(
            name: "DesignOSAppleCatalog",
            dependencies: ["DesignOSApple"]
        ),
        .executableTarget(
            name: "DesignOSAppleCatalogBundleTool",
            dependencies: ["DesignOSAppleCatalog"]
        ),
        .testTarget(
            name: "DesignOSAppleTests",
            dependencies: ["DesignOSApple", "DesignOSAppleExtensions"]
        ),
        .testTarget(
            name: "DesignOSAppleCatalogTests",
            dependencies: ["DesignOSAppleCatalog", "DesignOSAppleCatalogBundleTool"]
        ),
    ]
)
