// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataAccess",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "DataAccess", targets: ["DataAccess"]),
    ],
    dependencies: [
        .package(url: "../Domain", from: "1.0.0"),
        .package(url: "../Future", from: "1.0.0"),
    ],
    targets: [
        .target(name: "DataAccess", dependencies: ["Domain", "Future"]),
        .testTarget(name: "DataAccessTests", dependencies: ["DataAccess"]),
    ]
)
