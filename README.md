# Scalable iOS App Template

A modular iOS application template built with SwiftUI, Swift Package Manager,
initializer-based dependency injection, and a pragmatic Clean Architecture
approach.

The goal of this template is to provide a scalable starting point for
production iOS applications without introducing infrastructure or abstractions
before they are actually needed.

The template demonstrates:

- Feature-first modularization
- Clean Architecture boundaries
- MVVM presentation
- Swift Package Manager modules
- Compiler-enforced dependencies
- Initializer-based dependency injection
- Application and feature composition roots
- Build configuration with `.xcconfig`
- Interactive project setup
- Unit testing with Swift Testing
- Xcode Test Plans
- Integration with a reusable networking package

---

## Requirements

- Xcode with Swift 6 support
- iOS 17+
- Swift Package Manager

---

## Quick Setup

After cloning or creating a repository from this template, run:

```bash
./Scripts/setup.sh
```

The setup script configures:

- Application display name
- Bundle identifier
- API scheme
- API host
- Local secrets configuration

Example:

```text
App display name: My Awesome App
Bundle identifier: com.company.myawesomeapp
API scheme [https]:
API host [dummyjson.com]: api.example.com
```

The script updates the application's `.xcconfig` configuration without
modifying the Xcode project file.

After setup:

1. Review `Config/Secrets.xcconfig`.
2. Open `ScalableIOSAppTemplate.xcodeproj`.
3. Select a Development Team if required.
4. Build and run the application.
5. Run the configured unit test plan with `⌘ + U`.

> `Config/Secrets.xcconfig` is intentionally ignored by Git. Never commit
> production secrets, private tokens, signing credentials, or other sensitive
> values to source control.

### What the Setup Script Does Not Rename

The setup script configures application-facing values but intentionally does
not rename the technical Xcode project structure.

It does not rename:

```text
ScalableIOSAppTemplate.xcodeproj
ScalableIOSAppTemplate target
ScalableIOSAppTemplate scheme
ScalableIOSAppTemplate source folder
ScalableIOSAppTemplateApp type
Test target names
```

These names may be renamed manually if a complete project rename is desired.

The application can still use its real:

```text
Display Name
Bundle Identifier
API configuration
Secrets
```

without renaming the underlying Xcode project.

---

## Architecture

The project uses a modular variation of Clean Architecture.

A feature is normally split into four modules:

```text
FeatureDomain
FeatureData
FeatureInterface
FeatureAssembly
```

The dependency direction is:

```text
                   FeatureAssembly
                  /       |        \
                 ▼        ▼         ▼
              Domain     Data    Interface
                ▲         │         │
                └─────────┘         │
                ▲                   │
                └───────────────────┘

Data
 │
 ▼
External infrastructure
```

The most important rule is:

> Dependencies point toward the Domain layer.

The Domain layer does not know about UI, networking, persistence, or concrete
repository implementations.

For a detailed explanation of module responsibilities, dependency rules,
shared domain concepts, navigation, and scaling strategies, see
[Documentation/Architecture.md](Documentation/Architecture.md).

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
│   └── Architecture.md
│
├── Packages/
│   │
│   ├── CorePackage/
│   │   ├── Package.swift
│   │   ├── Sources/
│   │   │   ├── CoreDomain/
│   │   │   ├── CoreUI/
│   │   │   └── CoreUtilities/
│   │   └── Tests/
│   │
│   └── FeaturesPackage/
│       ├── Package.swift
│       ├── Sources/
│       │   ├── AuthenticationDomain/
│       │   ├── AuthenticationData/
│       │   ├── AuthenticationInterface/
│       │   └── AuthenticationAssembly/
│       └── Tests/
│           ├── AuthenticationDomainTests/
│           └── AuthenticationDataTests/
│
├── Scripts/
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
├── UnitTests.xctestplan
├── README.md
├── LICENSE
└── .gitignore
```

External dependencies are resolved through Swift Package Manager.

The example implementation currently uses `CoreNetworking` as its networking
package.

---

## Getting Started

### 1. Create a Project From the Template

Use the GitHub template repository functionality or clone the repository
directly.

```bash
git clone <repository-url>
cd ScalableIOSAppTemplate
```

For a new application, using GitHub's **Use this template** option is
recommended because the new repository starts with its own Git history.

### 2. Run the Setup Script

```bash
./Scripts/setup.sh
```

Configure the application name, bundle identifier, and API environment.

### 3. Open the Project

Open:

```text
ScalableIOSAppTemplate.xcodeproj
```

Xcode should resolve Swift Package dependencies automatically.

### 4. Configure Signing

If required, open the application target and select the appropriate
Development Team under:

```text
Signing & Capabilities
```

### 5. Configure Local Secrets

The setup script creates:

```text
Config/Secrets.xcconfig
```

from:

```text
Config/Secrets.example.xcconfig
```

Add any required local values there.

`Secrets.xcconfig` is ignored by Git.

### 6. Build and Test

Build and run the application.

Then run the complete configured unit test suite with:

```text
⌘ + U
```

---

## Manual Configuration

The setup script is optional.

All application-facing configuration can also be changed manually through:

```text
Config/Shared.xcconfig
```

For example:

```text
APP_DISPLAY_NAME = My Awesome App
APP_BUNDLE_IDENTIFIER = com.company.myawesomeapp

API_SCHEME = https
API_HOST = api.example.com
```

These values are wired into the Xcode build configuration.

The application display name is resolved through:

```text
APP_DISPLAY_NAME
    ↓
INFOPLIST_KEY_CFBundleDisplayName
    ↓
CFBundleDisplayName
```

The bundle identifier is resolved through:

```text
APP_BUNDLE_IDENTIFIER
    ↓
PRODUCT_BUNDLE_IDENTIFIER
    ↓
CFBundleIdentifier
```

This prevents application-specific values from being duplicated throughout
the Xcode project.

---

## Build Configuration

The project uses `.xcconfig` files to separate build configuration from
application code.

```text
Config/
├── Shared.xcconfig
├── Debug.xcconfig
├── Release.xcconfig
└── Secrets.example.xcconfig
```

### Shared Configuration

Contains values shared by build configurations.

Examples:

```text
Application display name
Bundle identifier
API configuration
Deployment target
Marketing version
Build number
```

### Debug Configuration

Contains development-specific settings.

Example:

```text
APP_ENVIRONMENT = development
ENABLE_APP_LOGGING = YES
```

### Release Configuration

Contains production-specific settings.

Example:

```text
APP_ENVIRONMENT = production
ENABLE_APP_LOGGING = NO
```

Environment-specific values are loaded into `AppConfiguration` and provided
to the application through the composition root.

---

## Secrets

Never commit secrets directly into the repository.

The repository contains:

```text
Config/Secrets.example.xcconfig
```

to document the local values an application may require.

The setup script creates:

```text
Config/Secrets.xcconfig
```

when it does not already exist.

Existing local secret values are preserved when the setup script is executed
again.

Do not commit:

```text
API keys
Private tokens
Signing secrets
Service credentials
Private certificates
```

to source control.

---

## Example Authentication Feature

The repository includes an Authentication feature as a reference
implementation.

It demonstrates the complete dependency flow:

```text
LoginView
    ↓
LoginViewModel
    ↓
LoginUseCase
    ↓
AuthenticationRepository
    ↑
DefaultAuthenticationRepository
    ↓
LoginEndpoint
    ↓
CoreNetworking
```

The example demonstrates:

- Domain models
- Repository abstractions
- Use cases
- Domain validation
- DTOs
- Mapping
- Endpoints
- Repository implementations
- ViewModels
- SwiftUI Views
- Feature Assembly
- Domain tests
- Data tests
- Networking integration

The Authentication feature is an example, not a mandatory part of the
architecture.

It may be adapted to the new application or removed completely.

---

## Removing the Example Authentication Feature

Remove the following source targets from `FeaturesPackage`:

```text
AuthenticationDomain
AuthenticationData
AuthenticationInterface
AuthenticationAssembly
```

Remove the corresponding test targets:

```text
AuthenticationDomainTests
AuthenticationDataTests
```

Then update:

```text
Packages/FeaturesPackage/Package.swift
```

and remove the corresponding:

```text
products
targets
test targets
dependencies that are no longer required
```

Also remove the Authentication feature construction from `AppContainer` and
replace the current root screen in `RootView`.

If no remaining feature uses `CoreNetworking`, the networking dependency may
also be removed.

After removing test targets, update:

```text
UnitTests.xctestplan
```

so it contains only valid test targets.

---

## Adding a New Feature

Suppose the application needs a Profile feature.

Create four new targets inside `FeaturesPackage`:

```text
ProfileDomain
ProfileData
ProfileInterface
ProfileAssembly
```

The structure becomes:

```text
FeaturesPackage/
└── Sources/
    ├── AuthenticationDomain/
    ├── AuthenticationData/
    ├── AuthenticationInterface/
    ├── AuthenticationAssembly/
    │
    ├── ProfileDomain/
    ├── ProfileData/
    ├── ProfileInterface/
    └── ProfileAssembly/
```

Register each new target in:

```text
Packages/FeaturesPackage/Package.swift
```

### ProfileDomain

Contains:

```text
Models
Repository protocols
Use cases
Business rules
Domain errors
```

Example:

```swift
public protocol ProfileRepository: Sendable {
    func profile() async throws -> UserProfile
}
```

Domain should not depend on:

```text
ProfileData
ProfileInterface
CoreNetworking
SwiftUI
```

### ProfileData

Contains implementation details such as:

```text
DTOs
Endpoints
Mappers
Repository implementations
```

Data may depend on:

```text
ProfileDomain
CoreNetworking
Persistence
Other required infrastructure
```

### ProfileInterface

Contains:

```text
State
ViewModels
Views
```

Interface may depend on:

```text
ProfileDomain
CoreUI
SwiftUI
```

It should not depend directly on:

```text
ProfileData
CoreNetworking
```

### ProfileAssembly

Creates the feature dependency graph.

```text
Repository
    ↓
UseCase
    ↓
ViewModel
    ↓
View
```

The application should normally depend on the Feature Assembly rather than
constructing every internal feature dependency itself.

---

## Package vs Feature

The template does not create a separate Swift Package for every feature.

`FeaturesPackage` acts as a container for independently compiled Swift
targets.

For example:

```text
FeaturesPackage
├── AuthenticationDomain
├── AuthenticationData
├── AuthenticationInterface
├── AuthenticationAssembly
│
├── ProfileDomain
├── ProfileData
├── ProfileInterface
└── ProfileAssembly
```

A separate Swift Package per feature can be introduced later if stronger
physical isolation becomes necessary.

Typical reasons include:

- Independent team ownership
- Independent release lifecycles
- Sharing features between multiple applications
- Stronger build isolation requirements

Do not introduce that complexity before it provides a concrete benefit.

---

## Dependency Injection

Initializer injection is the default dependency injection mechanism.

Example:

```swift
public final class LoginViewModel {

    private let loginUseCase: any LoginUseCase

    public init(
        loginUseCase: any LoginUseCase
    ) {
        self.loginUseCase = loginUseCase
    }
}
```

Global dependencies are constructed in:

```text
AppContainer
```

Feature-specific dependency graphs are constructed by Feature Assemblies.

Avoid using global singletons as the primary dependency mechanism.

---

## Networking

Networking is provided through the external `CoreNetworking` Swift Package.

The host application creates the concrete networking stack.

Feature Data modules depend on the networking abstraction they require.

```text
AppContainer
    ↓
NetworkClient
    ↓
AuthenticationFeatureBuilder
    ↓
DefaultAuthenticationRepository
```

Domain and Interface modules remain independent from networking
implementation details.

This keeps the architecture independent from a specific HTTP implementation.

---

## Testing

The project uses Swift Testing for unit tests.

Current examples include:

```text
CoreUtilitiesTests
AuthenticationDomainTests
AuthenticationDataTests
```

Domain tests verify business behavior.

Data tests verify responsibilities such as:

```text
DTO mapping
Endpoint configuration
Repository behavior
Interaction with infrastructure abstractions
```

Feature tests should not re-test implementation details already owned by
external packages.

For example, Authentication Data tests do not need to test `URLSession`,
HTTP response validation, or generic JSON decoding because those
responsibilities belong to `CoreNetworking`.

### Running Tests

The repository contains:

```text
UnitTests.xctestplan
```

Run the configured test suite from Xcode with:

```text
⌘ + U
```

When adding a new test target, also add it to `UnitTests.xctestplan`.

---

## Adding Infrastructure

There is intentionally no mandatory `InfrastructurePackage` in the initial
template.

Add infrastructure only when the application has a real requirement for it.

Examples:

```text
Persistence
Keychain
Analytics
Push Notifications
Location
Database
Feature Flags
```

A future application may introduce:

```text
InfrastructurePackage/
├── Persistence
├── SecurityKit
└── Analytics
```

The template intentionally avoids creating empty modules for hypothetical
future requirements.

---

## Core Modules

### CoreDomain

Contains small domain primitives that are genuinely shared across multiple
features.

Do not use `CoreDomain` as a generic model dump.

### CoreUI

Contains reusable SwiftUI components that are independent from specific
features.

### CoreUtilities

Contains small generic utilities shared across modules.

Avoid turning it into an unstructured `Helpers` collection.

---

## Dependency Rules

Use the following as the default dependency checklist:

```text
Domain
✓ Shared domain modules when required
✗ Data
✗ Interface
✗ CoreNetworking
✗ SwiftUI

Data
✓ Domain
✓ Required infrastructure
✗ Interface

Interface
✓ Domain
✓ CoreUI
✗ Data
✗ CoreNetworking

Assembly
✓ Domain
✓ Data
✓ Interface
✓ Required infrastructure

Application
✓ Feature assemblies
✓ Global infrastructure
✓ Root navigation
```

More advanced topics such as shared domain models, cross-feature navigation,
session state, package scaling, and application-level flow are documented in
[Documentation/Architecture.md](Documentation/Architecture.md).

---

## Design Principles

The template favors:

- Explicit dependencies
- Initializer injection
- Small focused modules
- Compiler-enforced boundaries
- Feature ownership
- Testable abstractions
- Composition at application boundaries
- Pragmatic architecture over unnecessary abstraction

The architecture should evolve with application requirements.

Do not add layers, protocols, packages, or services only because they may be
useful someday.

---

## License

This project is available under the MIT License.

See the [LICENSE](LICENSE) file for details.
