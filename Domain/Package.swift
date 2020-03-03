// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    dependencies: [
        .package(url: "../Future", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Domain", dependencies: ["Future"]),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
    ]
)
