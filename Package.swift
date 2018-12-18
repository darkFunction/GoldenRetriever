// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "GoldenRetriever",
    products: [
        .library(
            name: "GoldenRetriever",
            targets: ["GoldenRetriever"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "GoldenRetriever",
            dependencies: []),
        .testTarget(
            name: "GoldenRetrieverTests",
            dependencies: ["GoldenRetriever"]),
    ]
)
