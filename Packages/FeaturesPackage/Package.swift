// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FeaturesPackage",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AuthenticationDomain",
            targets: [
                "AuthenticationDomain"
            ]
        ),

        .library(
            name: "AuthenticationData",
            targets: [
                "AuthenticationData"
            ]
        ),

        .library(
            name: "AuthenticationInterface",
            targets: [
                "AuthenticationInterface"
            ]
        ),
        
        .library(
            name: "AuthenticationAssembly",
            targets: [
                "AuthenticationAssembly"
            ]
        ),
        
        // FEATURE_GENERATOR_PRODUCTS
    ],
    dependencies: [
        .package(
            path: "../SharedPackage"
        ),

        .package(
            url: "https://github.com/NikolaPopovic993/CoreNetworking.git",
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "AuthenticationDomain"
        ),

        .target(
            name: "AuthenticationData",
            dependencies: [
                "AuthenticationDomain",

                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            ]
        ),

        .target(
            name: "AuthenticationInterface",
            dependencies: [
                "AuthenticationDomain",

                .product(
                    name: "CoreUI",
                    package: "SharedPackage"
                )
            ]
        ),
        
        .target(
            name: "AuthenticationAssembly",
            dependencies: [
                "AuthenticationDomain",
                "AuthenticationData",
                "AuthenticationInterface",

                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            ]
        ),

        // FEATURE_GENERATOR_TARGETS
        
        .testTarget(
            name: "AuthenticationDomainTests",
            dependencies: [
                "AuthenticationDomain"
            ]
        ),
        
        .testTarget(
            name: "AuthenticationDataTests",
            dependencies: [
                "AuthenticationDomain",
                "AuthenticationData",

                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            ]
        ),
        
        // FEATURE_GENERATOR_TEST_TARGETS
    ]
)
