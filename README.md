# Scalable iOS App Template

A modular iOS application template built with SwiftUI, Swift Package Manager,
initializer-based dependency injection, and a pragmatic Clean Architecture
approach.

The template is designed to provide a scalable production-ready starting point
without introducing unnecessary abstractions before they are needed.

## Highlights

- Feature-first modularization
- Compiler-enforced module boundaries
- Clean Architecture separation
- MVVM presentation
- Swift Package Manager
- Initializer-based dependency injection
- Application and feature composition roots
- Automated project bootstrap
- Automated feature generation
- Configurable feature dependencies
- `.xcconfig` based configuration
- Local secrets handling
- Swift Testing
- Xcode Test Plans
- Reusable external infrastructure packages

---

## Requirements

- macOS
- Xcode with Swift 6.3 support
- iOS 17+
- Swift Package Manager

---

## Quick Start

Create a new repository using:

```text
Use this template
→ Create a new repository
```

Clone it:

```bash
git clone <your-repository-url>
cd <your-repository>
```

Then run:

```bash
./Scripts/bootstrap.sh
```

Bootstrap asks for:

```text
Technical project name
Application display name
Bundle identifier
API scheme
API host
```

Example:

```text
Technical project name: Biologer
App display name: Biologer
Bundle identifier: rs.biologer.app
API scheme: https
API host: dummyjson.com
```

After confirmation, the script automatically renames and configures the
application.

Then:

```text
1. Open the generated .xcodeproj
2. Review Config/Secrets.xcconfig
3. Select a Development Team if required
4. Build and run
5. Run tests with ⌘ + U
```

For detailed setup documentation, see:

[Project Setup](Documentation/Setup.md)

---

## Project Structure

```text
ScalableIOSAppTemplate/
│
├── Config/
│   ├── Debug.xcconfig
│   ├── Release.xcconfig
│   ├── Shared.xcconfig
│   └── Secrets.example.xcconfig
│
├── Documentation/
│   ├── Architecture.md
│   ├── FeatureGenerator.md
│   └── Setup.md
│
├── Packages/
│   │
│   ├── SharedPackage/
│   │   ├── Sources/
│   │   │   ├── SharedUI/
│   │   │   └── SharedUtilities/
│   │   └── Tests/
│   │
│   └── FeaturesPackage/
│       ├── Sources/
│       │   └── Authentication/
│       │       ├── Domain/
│       │       ├── Data/
│       │       ├── Interface/
│       │       └── Assembly/
│       │
│       └── Tests/
│           └── Authentication/
│               ├── DomainTests/
│               └── DataTests/
│
├── Scripts/
│   ├── bootstrap.sh
│   ├── generate_feature.sh
│   ├── rename_project.sh
│   └── setup.sh
│
├── ScalableIOSAppTemplate/
│   └── App/
│       ├── AppEntry/
│       ├── Composition/
│       ├── Configuration/
│       ├── Navigation/
│       └── Resources/
│
├── ScalableIOSAppTemplateTests/
├── ScalableIOSAppTemplateUITests/
│
├── ScalableIOSAppTemplate.xctestplan
├── README.md
└── LICENSE
```

---

## Architecture

Features are organized using a feature-first structure:

```text
Sources/
└── Profile/
    ├── Domain/
    ├── Data/
    ├── Interface/
    └── Assembly/
```

Each layer remains a separate Swift target:

```text
ProfileDomain
ProfileData
ProfileInterface
ProfileAssembly
```

This provides readable filesystem organization while preserving
compiler-enforced boundaries.

For detailed architecture rules, dependency direction, shared modules, and
scaling decisions, see:

[Architecture](Documentation/Architecture.md)

---

## Generate a Feature

Run:

```bash
./Scripts/generate_feature.sh
```

Example:

```text
Feature name: Profile
Use CoreNetworking? Y
Use SharedUI? Y
Create Domain and Data tests? Y
```

The generator creates:

```text
Sources/Profile/
├── Domain/
├── Data/
├── Interface/
└── Assembly/

Tests/Profile/
├── DomainTests/
└── DataTests/
```

and automatically registers the feature in `FeaturesPackage`.

For complete generator documentation and CLI options, see:

[Feature Generator](Documentation/FeatureGenerator.md)

---

## Feature Manifest

Features are registered declaratively:

```swift
FeatureConfiguration(
    name: "Authentication",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true
)
```

The manifest generates the required products, targets, paths, dependencies,
and optional test targets.

This keeps `Package.swift` compact as the application grows.

---

## SharedPackage

`SharedPackage` contains application-specific code that is genuinely shared
between features.

Current modules:

```text
SharedUI
SharedUtilities
```

Code should not be moved into `SharedPackage` simply because it is used in
multiple files.

Feature-specific code should remain owned by its feature.

Generic libraries intended for reuse across multiple applications should
preferably live in separate repositories and be integrated through Swift
Package Manager.

---

## Example Authentication Feature

Authentication is included as a reference implementation demonstrating:

- Domain models
- Repository abstractions
- Use cases
- DTOs
- Endpoints
- Mapping
- Repository implementations
- ViewModels
- SwiftUI Views
- Feature Assembly
- Networking integration
- Shared UI integration
- Domain tests
- Data tests

It can be adapted or removed when starting a real application.

---

## Testing

The project uses Swift Testing.

Current examples include:

```text
SharedUtilitiesTests
AuthenticationDomainTests
AuthenticationDataTests
```

Run the configured Xcode Test Plan with:

```text
⌘ + U
```

New feature test targets generated by the feature generator should be reviewed
and added to the Xcode Test Plan when required.

---

## Documentation

Detailed documentation:

- [Architecture](Documentation/Architecture.md)
- [Feature Generator](Documentation/FeatureGenerator.md)
- [Project Setup](Documentation/Setup.md)

---

## License

This project is available under the MIT License.

See [LICENSE](LICENSE) for details.
