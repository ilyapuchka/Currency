// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignLibrary",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "DesignLibrary", targets: ["DesignLibrary"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "DesignLibrary", dependencies: []),
        .testTarget(name: "DesignLibraryTests", dependencies: ["DesignLibrary"]),
    ]
)
