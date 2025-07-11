// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FractalGenerators",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FractalGenerators",
            targets: ["FractalGenerators"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FractalGenerators",
            dependencies: [.product(name: "ComplexModule", package: "swift-numerics")]
        ),
        .testTarget(
            name: "FractalGeneratorsTests",
            dependencies: ["FractalGenerators"]
        ),
    ]
)
