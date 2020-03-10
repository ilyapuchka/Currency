// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConverterFeature",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "ConverterFeature", targets: ["ConverterFeature"])
    ],
    dependencies: [
        .package(url: "../DesignLibrary", from: "1.0.0"),
        .package(url: "../Domain", from: "1.0.0"),
    ],
    targets: [
        .target(name: "ConverterFeature", dependencies: ["DesignLibrary", "Domain"]),
        .testTarget(name: "ConverterFeatureTests", dependencies: ["ConverterFeature"]),
    ]
)
