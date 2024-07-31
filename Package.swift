// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

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
            from: "2.0.0"),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0")
    ],
    targets: [
        
        // Macros and Macros Tests
        .macro(
            name: "LambdaspireDependencyResolutionMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "LambdaspireDependencyResolutionMacrosTests",
            dependencies: [
                "LambdaspireDependencyResolutionMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]),
        
        // Library and Library Tests
        .target(
            name: "LambdaspireDependencyResolution",
            dependencies: [
                "LambdaspireDependencyResolutionMacros",
                .product(name: "LambdaspireAbstractions", package: "Lambdaspire-Swift-Abstractions")
            ]),
        .testTarget(
            name: "LambdaspireDependencyResolutionTests",
            dependencies: [
                "LambdaspireDependencyResolution"
            ]),
    ]
)
