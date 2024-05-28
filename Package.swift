// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LambdaspireDependencyResolution",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "LambdaspireDependencyResolution",
            targets: ["LambdaspireDependencyResolution"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Lambdaspire/Lambdaspire-Swift-Abstractions",
            from: "1.0.0")
    ],
    targets: [
        .target(
            name: "LambdaspireDependencyResolution",
            dependencies: [
                .product(name: "LambdaspireAbstractions", package: "Lambdaspire-Swift-Abstractions")
            ]),
        .testTarget(
            name: "LambdaspireDependencyResolutionTests",
            dependencies: ["LambdaspireDependencyResolution"]),
    ]
)
