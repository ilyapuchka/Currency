// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Future",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Future", targets: ["Future"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Future", dependencies: []),
        .testTarget(name: "FutureTests", dependencies: ["Future"]),
    ]
)
