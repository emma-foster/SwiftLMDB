// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftLMDB",
    products: [
        .library(name: "SwiftLMDB", targets: ["SwiftLMDB"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jernejstrasner/CLMDB.git", from: "0.1.2"),
    ],
    targets: [
        .target(name: "SwiftLMDB", dependencies: ["CLMDB"]),
        .testTarget(name: "SwiftLMDBTests", dependencies: ["SwiftLMDB"]),
    ]
)
