# Scalable iOS App Template

A modular iOS application template built with SwiftUI, Swift Package Manager,
initializer-based dependency injection, and a pragmatic Clean Architecture
approach.

The template provides a scalable starting point for production iOS
applications without introducing unnecessary abstractions before they are
needed.

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
- Explicit layer-specific dependencies
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

Run:

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
Application display name: Biologer
Bundle identifier: rs.biologer.app
API scheme: https
API host: dummyjson.com
```

After confirmation, the script renames and configures the application.

Then:

```text
1. Open the generated .xcodeproj
2. Review Config/Secrets.xcconfig
3. Select a Development Team if required
4. Build and run
5. Run tests with ⌘ + U
```

For detailed setup documentation:

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

Features use a feature-first physical structure:

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

This provides readable feature ownership while preserving compiler-enforced
boundaries.

For detailed architecture rules:

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

For all generator options:

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

The manifest generates products, targets, paths, common dependencies, and
optional test targets.

Feature-specific dependencies can be added explicitly to the layer that
requires them.

Example:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true,
    dataDependencies: [
        .product(
            name: "SharedUtilities",
            package: "SharedPackage"
        )
    ]
)
```

This makes `SharedUtilities` available to `ProfileData` without exposing it
to every other Profile module.

---

## SharedPackage

`SharedPackage` contains application-specific code that is genuinely shared
between features.

Current modules:

```text
SharedUI
SharedUtilities
```

Feature-specific code should remain owned by its feature.

Generic libraries intended for reuse across multiple applications should
preferably live in separate repositories and be integrated through Swift
Package Manager.

---

## Dependency Strategy

The template follows this general rule:

```text
Used only by one feature
        ↓
Keep inside the feature

Application-specific and shared by multiple features
        ↓
SharedPackage

Generic and reusable across applications
        ↓
Separate Swift Package
```

Common dependencies such as `CoreNetworking` and `SharedUI` can be configured
through the feature generator.

More specific dependencies are added explicitly to the feature layer that
consumes them.

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

When new feature test targets are generated, verify that they are included in
the Xcode Test Plan when required.

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
