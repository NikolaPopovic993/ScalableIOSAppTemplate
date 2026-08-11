// swift-tools-version: 6.3

import PackageDescription

// MARK: - Feature Module

enum FeatureModule: CaseIterable {

    case domain
    case data
    case interface
    case assembly
}


// MARK: - Feature Configuration

struct FeatureConfiguration {

    let name: String
    let modules: [FeatureModule]

    let usesNetworking: Bool
    let usesSharedUI: Bool
    let hasTests: Bool

    let domainDependencies: [Target.Dependency]
    let dataDependencies: [Target.Dependency]
    let interfaceDependencies: [Target.Dependency]
    let assemblyDependencies: [Target.Dependency]

    init(
        name: String,
        modules: [FeatureModule] = [
            .domain,
            .data,
            .interface,
            .assembly
        ],
        usesNetworking: Bool,
        usesSharedUI: Bool,
        hasTests: Bool,
        domainDependencies: [Target.Dependency] = [],
        dataDependencies: [Target.Dependency] = [],
        interfaceDependencies: [Target.Dependency] = [],
        assemblyDependencies: [Target.Dependency] = []
    ) {
        precondition(
            !modules.isEmpty,
            "Feature '\(name)' must contain at least one module."
        )

        self.name = name
        self.modules = modules
        self.usesNetworking = usesNetworking
        self.usesSharedUI = usesSharedUI
        self.hasTests = hasTests
        self.domainDependencies = domainDependencies
        self.dataDependencies = dataDependencies
        self.interfaceDependencies = interfaceDependencies
        self.assemblyDependencies = assemblyDependencies
    }

    // MARK: Target Names

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

    // MARK: Products

    var products: [Product] {
        enabledModules.map { module in
            let targetName = targetName(for: module)

            return .library(
                name: targetName,
                targets: [
                    targetName
                ]
            )
        }
    }

    // MARK: Targets

    var targets: [Target] {
        var result = enabledModules.map {
            makeTarget(for: $0)
        }

        if hasTests {
            if contains(.domain) {
                result.append(
                    makeDomainTestsTarget()
                )
            }

            if contains(.data) {
                result.append(
                    makeDataTestsTarget()
                )
            }
        }

        return result
    }

    // MARK: Enabled Modules

    private var enabledModules: [FeatureModule] {
        FeatureModule.allCases.filter {
            modules.contains($0)
        }
    }

    private func contains(
        _ module: FeatureModule
    ) -> Bool {
        modules.contains(module)
    }

    // MARK: Module Information

    private func targetName(
        for module: FeatureModule
    ) -> String {
        switch module {
        case .domain:
            domainTargetName

        case .data:
            dataTargetName

        case .interface:
            interfaceTargetName

        case .assembly:
            assemblyTargetName
        }
    }

    // MARK: Target Factory

    private func makeTarget(
        for module: FeatureModule
    ) -> Target {
        switch module {
        case .domain:
            makeDomainTarget()

        case .data:
            makeDataTarget()

        case .interface:
            makeInterfaceTarget()

        case .assembly:
            makeAssemblyTarget()
        }
    }

    // MARK: Domain

    private func makeDomainTarget() -> Target {
        .target(
            name: domainTargetName,
            dependencies: domainDependencies,
            path: "Sources/\(name)/Domain"
        )
    }

    // MARK: Data

    private func makeDataTarget() -> Target {
        var dependencies: [Target.Dependency] = []

        if contains(.domain) {
            dependencies.append(
                .target(
                    name: domainTargetName
                )
            )
        }

        dependencies.append(
            contentsOf: dataDependencies
        )

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

    // MARK: Interface

    private func makeInterfaceTarget() -> Target {
        var dependencies: [Target.Dependency] = []

        if contains(.domain) {
            dependencies.append(
                .target(
                    name: domainTargetName
                )
            )
        }

        dependencies.append(
            contentsOf: interfaceDependencies
        )

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

    // MARK: Assembly

    private func makeAssemblyTarget() -> Target {
        var dependencies: [Target.Dependency] = []

        if contains(.domain) {
            dependencies.append(
                .target(
                    name: domainTargetName
                )
            )
        }

        if contains(.data) {
            dependencies.append(
                .target(
                    name: dataTargetName
                )
            )
        }

        if contains(.interface) {
            dependencies.append(
                .target(
                    name: interfaceTargetName
                )
            )
        }

        dependencies.append(
            contentsOf: assemblyDependencies
        )

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

    // MARK: Domain Tests

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

    // MARK: Data Tests

    private func makeDataTestsTarget() -> Target {
        var dependencies: [Target.Dependency] = [
            .target(
                name: dataTargetName
            )
        ]

        if contains(.domain) {
            dependencies.append(
                .target(
                    name: domainTargetName
                )
            )
        }

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
        modules: [
            .domain,
            .data,
            .interface,
            .assembly
        ],
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
