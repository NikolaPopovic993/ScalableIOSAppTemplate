# Scalable iOS App Template

A production-oriented iOS application template built with SwiftUI, Swift
Package Manager, feature-first modularization, explicit dependency injection,
and pragmatic Clean Architecture principles.

The template is designed for applications that may grow over time while
keeping feature ownership, dependencies, testing, and project setup explicit.

## Highlights

- SwiftUI application structure
- Feature-first modularization
- Flexible feature composition
- Swift Package Manager target boundaries
- Pragmatic Clean Architecture
- MVVM where presentation state requires it
- Initializer-based dependency injection
- Application Composition Root
- Reusable `SharedPackage`
- Remote `CoreNetworking` dependency
- Feature generator
- Environment configuration with `.xcconfig`
- Bootstrap and project rename scripts
- GitHub Actions pull request CI
- Xcode Test Plan
- Unit-test friendly architecture

## Requirements

The template targets:

```text
iOS 17+
```

The project uses modern Swift and Swift Package Manager tooling.

Use a recent Xcode version capable of building the Swift toolchain declared by
the packages.

## Getting Started

The fastest way to start a new project is to create a fresh copy of the
repository and run:

```bash
./Scripts/bootstrap.sh
```

The bootstrap workflow combines the initial project rename and application
configuration steps.

It is intended to be run from a clean Git working tree.

For detailed setup instructions see:

[Setup](Documentation/Setup.md)

## Project Structure

The repository is organized approximately as:

```text
ScalableIOSAppTemplate/
├── ScalableIOSAppTemplate/
│   └── App/
│       ├── AppEntry/
│       ├── Composition/
│       ├── Configuration/
│       ├── Navigation/
│       └── Resources/
│
├── Packages/
│   ├── FeaturesPackage/
│   └── SharedPackage/
│
├── Config/
│   ├── Shared.xcconfig
│   ├── Debug.xcconfig
│   ├── Release.xcconfig
│   └── Secrets.example.xcconfig
│
├── Documentation/
│   ├── Architecture.md
│   ├── CI.md
│   ├── FeatureGenerator.md
│   └── Setup.md
│
├── Scripts/
│   ├── bootstrap.sh
│   ├── generate_feature.sh
│   ├── rename_project.sh
│   └── setup.sh
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
└── ScalableIOSAppTemplate.xctestplan
```

## Architecture

The template uses feature-first modularization with optional
compiler-enforced architectural boundaries:

```text
Domain
Data
Interface
Assembly
```

A feature does not need to contain every module.

Use only the modules that provide meaningful separation for that feature.

For example:

```text
Authentication
├── Domain
├── Data
├── Interface
└── Assembly
```

while a simple feature may contain only:

```text
About
└── Interface
```

and a background capability may use:

```text
BackgroundSync
├── Domain
├── Data
└── Assembly
```

The architecture is intentionally pragmatic.

Do not introduce layers that do not provide meaningful ownership, dependency,
testing, or composition boundaries.

For the full architectural description see:

[Architecture](Documentation/Architecture.md)

## FeaturesPackage

Application features live inside:

```text
Packages/FeaturesPackage
```

The package is physically organized by feature.

For example:

```text
Sources/
└── Authentication/
    ├── Domain/
    ├── Data/
    ├── Interface/
    └── Assembly/
```

Swift Package Manager still treats these directories as independent targets:

```text
AuthenticationDomain
AuthenticationData
AuthenticationInterface
AuthenticationAssembly
```

This gives the project feature-oriented organization while preserving
compiler-enforced dependency boundaries.

## Flexible Feature Composition

Feature architecture can grow incrementally.

A feature can start with:

```text
Profile
├── Domain
└── Data
```

and later become:

```text
Profile
├── Domain
├── Data
└── Interface
```

and, if dependency composition becomes complex enough:

```text
Profile
├── Domain
├── Data
├── Interface
└── Assembly
```

The structure selected when a feature is created is not permanent.

## Feature Generator

Create a new feature interactively:

```bash
./Scripts/generate_feature.sh
```

or from the command line:

```bash
./Scripts/generate_feature.sh \
    --name Profile \
    --modules domain,data,interface,assembly \
    --networking \
    --tests \
    --yes
```

Features can contain only the architectural modules they actually need.

Examples:

```text
About
└── Interface
```

```text
Calculator
├── Domain
└── Interface
```

```text
BackgroundSync
├── Domain
├── Data
└── Assembly
```

The generator supports:

```text
domain
data
interface
assembly
all
```

as module selections.

Feature modules can also be added manually later as the feature grows.

For complete generator documentation see:

[Feature Generator](Documentation/FeatureGenerator.md)

## Feature Configuration

Features are registered inside:

```text
Packages/FeaturesPackage/Package.swift
```

using `FeatureConfiguration`.

For example:

```swift
FeatureConfiguration(
    name: "Authentication",
    modules: [
        .domain,
        .data,
        .interface,
        .assembly
    ],
    usesNetworking: true,
    hasTests: true,
    interfaceDependencies: [
        .product(
            name: "SharedUI",
            package: "SharedPackage"
        )
    ]
)
```

The configuration determines:

```text
Which modules exist
Whether CoreNetworking is required
Whether supported test targets are created
Which additional dependencies each module requires
```

Additional dependencies are explicit:

```swift
domainDependencies
dataDependencies
interfaceDependencies
assemblyDependencies
```

This avoids creating configuration flags for every possible dependency.

## SharedPackage

Application-specific reusable code lives inside:

```text
Packages/SharedPackage
```

The package currently provides modules such as:

```text
SharedUI
SharedUtilities
```

Use the following ownership rule:

```text
Used by one feature
→ keep inside the feature

App-specific and shared between features
→ SharedPackage

Generic and reusable across applications
→ separate reusable Swift package
```

`SharedPackage` should not become a dumping ground for unrelated code.

## Reusable Packages

Generic libraries that can be reused across applications should remain
independent Swift packages.

The template currently integrates:

```text
CoreNetworking
```

as a remote Swift Package dependency.

Feature infrastructure can opt into it using:

```swift
usesNetworking: true
```

The networking dependency is kept outside Domain and presentation concerns.

## Dependency Injection

The preferred dependency injection approach is:

```text
Initializer Injection
```

Application-level dependencies are created in the Composition Root and passed
to the modules that require them.

The application should avoid using global singletons or SwiftUI Environment as
a general-purpose service locator.

## Composition Root

Top-level dependency composition belongs to the application.

The primary composition object is:

```text
AppContainer
```

It is responsible for creating and connecting application-level dependencies
and feature entry points.

Feature-level dependency construction may additionally live inside a feature's
Assembly module when such a boundary provides value.

## Using Feature Products

Adding a feature to `FeaturesPackage` creates its SwiftPM products, but the host
application target should explicitly depend on the product it uses.

For example:

```text
About
└── AboutInterface
```

can be exposed to the application by adding:

```text
AboutInterface
```

to the application target.

The application can then:

```swift
import AboutInterface
```

A more complex feature may expose its entry point through:

```text
AuthenticationAssembly
```

This keeps application dependencies explicit.

## Configuration

Application configuration is managed through `.xcconfig` files:

```text
Config/
├── Shared.xcconfig
├── Debug.xcconfig
├── Release.xcconfig
└── Secrets.example.xcconfig
```

Configuration can include values such as:

```text
Application display name
Bundle identifier
API scheme
API host
Application version
Build number
Environment
Logging configuration
```

Avoid storing real secrets in tracked configuration files.

See:

[Setup](Documentation/Setup.md)

for configuration details.

## Testing

The repository uses an Xcode Test Plan:

```text
ScalableIOSAppTemplate.xctestplan
```

Feature tests are organized next to their owning feature inside
`FeaturesPackage`.

The default feature generator currently supports:

```text
DomainTests
DataTests
```

when their corresponding modules exist.

Tests should follow module responsibilities.

For example:

```text
DomainTests
→ business rules, validation, use cases

DataTests
→ repositories, DTO mapping, persistence, networking behavior
```

## Continuous Integration

Pull requests targeting `main` are validated with GitHub Actions.

The standard PR CI verifies:

```text
Shell script syntax
SharedPackage manifest
FeaturesPackage manifest
iOS application build
Configured tests
```

The workflow is located at:

```text
.github/workflows/ci.yml
```

Deployment, signing, Fastlane, TestFlight, and App Store delivery are
intentionally outside the standard template CI.

For details see:

[Continuous Integration](Documentation/CI.md)

## Scripts

The repository includes several developer workflow scripts.

### Bootstrap

```bash
./Scripts/bootstrap.sh
```

Performs the initial project bootstrap workflow.

### Rename Project

```bash
./Scripts/rename_project.sh
```

Renames the template project.

### Configure Project

```bash
./Scripts/setup.sh
```

Configures application-specific values.

### Generate Feature

```bash
./Scripts/generate_feature.sh
```

Creates the initial structure for a feature.

See the detailed documentation before modifying these scripts because some of
them intentionally require a clean Git working tree.

## Documentation

Detailed documentation is kept outside the README so the repository overview
remains concise.

- [Architecture](Documentation/Architecture.md)
- [Feature Generator](Documentation/FeatureGenerator.md)
- [Setup](Documentation/Setup.md)
- [Continuous Integration](Documentation/CI.md)

## Design Philosophy

The template is designed around one central idea:

> Architecture should provide useful boundaries without forcing unnecessary
> layers.

Start small.

Keep feature ownership explicit.

Introduce dependencies deliberately.

Add modules when feature responsibilities justify them.

Extract reusable packages when reuse actually exists.

The template provides structure for growth without requiring every feature to
start with maximum complexity.
