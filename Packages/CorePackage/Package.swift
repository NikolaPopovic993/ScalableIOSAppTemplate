// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CorePackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreDomain",
            targets: ["CoreDomain"]
        ),
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]
        ),
        .library(
            name: "CoreUtilities",
            targets: ["CoreUtilities"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreDomain"
        ),
        .target(
            name: "CoreUI"
        ),
        .target(
            name: "CoreUtilities"
        ),
        .testTarget(
            name: "CoreUtilitiesTests",
            dependencies: ["CoreUtilities"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
