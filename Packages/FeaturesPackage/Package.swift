// swift-tools-version: 6.3

import PackageDescription

// MARK: - Feature Configuration

struct FeatureConfiguration {

    let name: String
    let usesNetworking: Bool
    let usesSharedUI: Bool
    let hasTests: Bool

    var domainTargetName: String {
        "\(name)Domain"
    }

    var dataTargetName: String {
        "\(name)Data"
    }

    var interfaceTargetName: String {
        "\(name)Interface"
    }

    var assemblyTargetName: String {
        "\(name)Assembly"
    }

    var domainTestsTargetName: String {
        "\(name)DomainTests"
    }

    var dataTestsTargetName: String {
        "\(name)DataTests"
    }

    var products: [Product] {
        [
            .library(
                name: domainTargetName,
                targets: [
                    domainTargetName
                ]
            ),

            .library(
                name: dataTargetName,
                targets: [
                    dataTargetName
                ]
            ),

            .library(
                name: interfaceTargetName,
                targets: [
                    interfaceTargetName
                ]
            ),

            .library(
                name: assemblyTargetName,
                targets: [
                    assemblyTargetName
                ]
            )
        ]
    }

    var targets: [Target] {
        var targets: [Target] = [
            makeDomainTarget(),
            makeDataTarget(),
            makeInterfaceTarget(),
            makeAssemblyTarget()
        ]

        if hasTests {
            targets.append(makeDomainTestsTarget())
            targets.append(makeDataTestsTarget())
        }

        return targets
    }

    private func makeDomainTarget() -> Target {
        .target(
            name: domainTargetName,
            path: "Sources/\(name)/Domain"
        )
    }

    private func makeDataTarget() -> Target {
        var dependencies: [Target.Dependency] = [
            .target(
                name: domainTargetName
            )
        ]

        if usesNetworking {
            dependencies.append(
                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            )
        }

        return .target(
            name: dataTargetName,
            dependencies: dependencies,
            path: "Sources/\(name)/Data"
        )
    }

    private func makeInterfaceTarget() -> Target {
        var dependencies: [Target.Dependency] = [
            .target(
                name: domainTargetName
            )
        ]

        if usesSharedUI {
            dependencies.append(
                .product(
                    name: "SharedUI",
                    package: "SharedPackage"
                )
            )
        }

        return .target(
            name: interfaceTargetName,
            dependencies: dependencies,
            path: "Sources/\(name)/Interface"
        )
    }

    private func makeAssemblyTarget() -> Target {
        var dependencies: [Target.Dependency] = [
            .target(
                name: domainTargetName
            ),

            .target(
                name: dataTargetName
            ),

            .target(
                name: interfaceTargetName
            )
        ]

        if usesNetworking {
            dependencies.append(
                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            )
        }

        return .target(
            name: assemblyTargetName,
            dependencies: dependencies,
            path: "Sources/\(name)/Assembly"
        )
    }

    private func makeDomainTestsTarget() -> Target {
        .testTarget(
            name: domainTestsTargetName,
            dependencies: [
                .target(
                    name: domainTargetName
                )
            ],
            path: "Tests/\(name)/DomainTests"
        )
    }

    private func makeDataTestsTarget() -> Target {
        var dependencies: [Target.Dependency] = [
            .target(
                name: domainTargetName
            ),

            .target(
                name: dataTargetName
            )
        ]

        if usesNetworking {
            dependencies.append(
                .product(
                    name: "CoreNetworking",
                    package: "CoreNetworking"
                )
            )
        }

        return .testTarget(
            name: dataTestsTargetName,
            dependencies: dependencies,
            path: "Tests/\(name)/DataTests"
        )
    }
}


// MARK: - Features

let features: [FeatureConfiguration] = [
    FeatureConfiguration(
        name: "Authentication",
        usesNetworking: true,
        usesSharedUI: true,
        hasTests: true
    ),

    // FEATURE_GENERATOR_FEATURES
]


// MARK: - Package

let package = Package(
    name: "FeaturesPackage",
    platforms: [
        .iOS(.v17)
    ],
    products: features.flatMap(\.products),
    dependencies: [
        .package(
            path: "../SharedPackage"
        ),

        .package(
            url: "https://github.com/NikolaPopovic993/CoreNetworking.git",
            from: "2.0.0"
        )
    ],
    targets: features.flatMap(\.targets)
)
