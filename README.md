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
- Automated project bootstrap
- Automated Xcode project rename
- Local secrets configuration
- Unit testing with Swift Testing
- Xcode Test Plans
- Integration with a reusable networking package

---

## Requirements

- Xcode with Swift 6 support
- iOS 17+
- Swift Package Manager
- macOS

---

## Quick Start

The recommended way to start a new application is to create a repository from
this GitHub template and run the bootstrap script.

### 1. Create a Repository From the Template

Use:

```text
Use this template
→ Create a new repository
```

on GitHub.

Then clone the newly created repository:

```bash
git clone <your-new-repository-url>
cd <your-new-repository>
```

### 2. Run Bootstrap

Run:

```bash
./Scripts/bootstrap.sh
```

The bootstrap script asks for:

- Technical Xcode project name
- Application display name
- Bundle identifier
- API scheme
- API host

Example:

```text
Technical project name [MyAwesomeApp]: Biologer
App display name [My Awesome App]: Biologer
Bundle identifier [com.example.myawesomeapp]: rs.biologer.app
API scheme [https]:
API host [dummyjson.com]:
```

Before making any changes, the script displays a summary:

```text
Application Configuration
========================================

Technical project name:
  Biologer

Application display name:
  Biologer

Bundle identifier:
  rs.biologer.app

API:
  https://dummyjson.com

========================================

Create this application? [Y/n]:
```

After confirmation, the complete project setup is performed automatically.

The bootstrap process:

1. Renames the Xcode project.
2. Renames application target references.
3. Renames the shared scheme.
4. Renames the application source directory.
5. Renames unit test and UI test directories.
6. Renames the SwiftUI App entry point.
7. Renames test source references.
8. Renames the Xcode Test Plan.
9. Configures the application display name.
10. Configures the bundle identifier.
11. Configures the API scheme and host.
12. Creates the local secrets configuration.

After bootstrap, the project is ready to open in Xcode.

For example:

```text
Biologer.xcodeproj
```

### 3. Open the Project

Open the generated `.xcodeproj` file.

Then:

1. Review `Config/Secrets.xcconfig`.
2. Select a Development Team if required.
3. Build and run the application.
4. Run the configured tests with `⌘ + U`.

> Run `bootstrap.sh` on a clean Git working tree immediately after creating
> or cloning a repository from this template.

> `Config/Secrets.xcconfig` is intentionally ignored by Git. Never commit
> production secrets, private tokens, signing credentials, certificates, or
> other sensitive values to source control.

---

## What Bootstrap Configures

The bootstrap process separates the technical Xcode project identity from the
application-facing identity.

For example:

```text
Technical project name:
Biologer

Application display name:
Biologer

Bundle identifier:
rs.biologer.app
```

The technical project name is used for:

```text
Biologer.xcodeproj
Biologer target
Biologer scheme
Biologer/
BiologerTests/
BiologerUITests/
Biologer.xctestplan
BiologerApp.swift
```

The application-facing configuration is stored in `.xcconfig`:

```text
APP_DISPLAY_NAME = Biologer
APP_BUNDLE_IDENTIFIER = rs.biologer.app

API_SCHEME = https
API_HOST = dummyjson.com
```

This keeps Xcode project configuration centralized and avoids duplicating
application-specific values throughout the project.

---

## Advanced Setup

The bootstrap workflow is composed of two smaller scripts:

```text
Scripts/
├── bootstrap.sh
├── rename_project.sh
└── setup.sh
```

For normal template usage:

```bash
./Scripts/bootstrap.sh
```

is recommended.

The smaller scripts can also be used independently.

### Rename Only the Xcode Project

Interactive:

```bash
./Scripts/rename_project.sh
```

Non-interactive:

```bash
./Scripts/rename_project.sh \
    --name MyAwesomeApp \
    --yes
```

This script performs the technical project rename but does not change the
application display name, bundle identifier, API configuration, or secrets.

### Configure Only Application Values

Interactive:

```bash
./Scripts/setup.sh
```

Non-interactive:

```bash
./Scripts/setup.sh \
    --display-name "My Awesome App" \
    --bundle-id "com.company.myawesomeapp" \
    --api-scheme "https" \
    --api-host "api.example.com" \
    --yes
```

This script changes application-facing configuration without performing the
technical project rename.

---

## Bootstrap Recovery

The bootstrap script requires a clean Git working tree.

This makes it easy to inspect or discard generated changes if something goes
wrong.

Review changes with:

```bash
git status
```

For a fresh repository created from the template, bootstrap changes can be
discarded with:

```bash
git reset --hard HEAD
git clean -fd
```

> `git clean -fd` removes untracked files and directories. Use it only when
> you understand which files will be deleted.

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
shared domain concepts, navigation, session state, and scaling strategies, see:

[Documentation/Architecture.md](Documentation/Architecture.md)

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
│   ├── bootstrap.sh
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
├── LICENSE
└── .gitignore
```

External dependencies are resolved through Swift Package Manager.

The example implementation uses `CoreNetworking` as its networking package.

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

Contains configuration shared across build environments.

Examples:

```text
APP_DISPLAY_NAME
APP_BUNDLE_IDENTIFIER

API_SCHEME
API_HOST

MARKETING_VERSION
CURRENT_PROJECT_VERSION
IPHONEOS_DEPLOYMENT_TARGET
```

Application identity is wired through build settings:

```text
APP_DISPLAY_NAME
    ↓
INFOPLIST_KEY_CFBundleDisplayName
    ↓
CFBundleDisplayName
```

Bundle identifier:

```text
APP_BUNDLE_IDENTIFIER
    ↓
PRODUCT_BUNDLE_IDENTIFIER
    ↓
CFBundleIdentifier
```

This prevents application-specific values from being hardcoded in multiple
places.

### Debug Configuration

Contains development-specific configuration.

Example:

```text
APP_ENVIRONMENT = development
ENABLE_APP_LOGGING = YES
```

### Release Configuration

Contains production-specific configuration.

Example:

```text
APP_ENVIRONMENT = production
ENABLE_APP_LOGGING = NO
```

Configuration values are loaded into `AppConfiguration` and provided to the
application through the Composition Root.

---

## Secrets

Never commit secrets directly into the repository.

The repository contains:

```text
Config/Secrets.example.xcconfig
```

to document local configuration values that an application may require.

During bootstrap, the template creates:

```text
Config/Secrets.xcconfig
```

if it does not already exist.

Existing local secret values are preserved when `setup.sh` is executed again.

`Secrets.xcconfig` is ignored by Git.

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
- DTO-to-Domain mapping
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

Remove the following targets from `FeaturesPackage`:

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

Also remove Authentication feature construction from:

```text
AppContainer
```

and replace the current root screen in:

```text
RootView
```

with the first flow or feature of the new application.

After removing test targets, update the Xcode Test Plan so it contains only
valid test targets.

If no remaining feature uses `CoreNetworking`, the networking dependency may
also be removed.

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

Contains presentation code:

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

Creates the feature dependency graph:

```text
Repository
    ↓
UseCase
    ↓
ViewModel
    ↓
View
```

The application should normally depend on the Feature Assembly instead of
constructing every internal feature dependency itself.

---

## Package vs Feature

The template does not create a separate Swift Package for every feature.

Instead, `FeaturesPackage` acts as a container for independently compiled
Swift targets.

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

## Composition

The application uses two composition levels.

### Application Composition Root

`AppContainer` creates application-wide dependencies such as:

```text
Networking
Shared configuration
Feature builders
Application-level services
```

### Feature Assembly

Each feature creates its own internal dependency graph.

Example:

```text
AuthenticationFeatureBuilder
        ↓
DefaultAuthenticationRepository
        ↓
DefaultLoginUseCase
        ↓
LoginViewModel
        ↓
LoginView
```

The host application therefore does not need to know how every object inside a
feature is created.

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

This keeps business logic independent from a specific HTTP implementation.

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
generic HTTP response validation, or generic JSON decoding because those
responsibilities belong to `CoreNetworking`.

### Test Plan

The repository includes an Xcode Test Plan.

Before bootstrap:

```text
ScalableIOSAppTemplate.xctestplan
```

After bootstrap, the test plan is automatically renamed together with the
project.

For example:

```text
Biologer.xctestplan
```

Run the configured tests with:

```text
⌘ + U
```

When adding a new test target, also add it to the project's Test Plan.

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
Deep Links
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

Contains domain primitives that are genuinely shared across multiple
features.

Do not use `CoreDomain` as a generic model dump.

If a substantial shared business concept emerges, consider creating a
dedicated domain module such as:

```text
UserDomain
SessionDomain
```

instead.

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
session state, package scaling, and application-level flow are documented in:

[Documentation/Architecture.md](Documentation/Architecture.md)

---

## Cross-Feature Navigation

Features should not navigate directly into other features.

Avoid:

```text
ProfileFeature
    ↓
AuthenticationFeature
```

Instead, a feature should expose an event or update application-level state:

```text
Profile
    ↓
Logout requested
    ↓
Application / Session state
    ↓
Root navigation
    ↓
Authentication flow
```

Root-level navigation belongs to the Application layer.

This prevents feature-to-feature dependency cycles.

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

## Recommended Workflow

For a new project:

```text
Use this template
        ↓
Create repository
        ↓
Clone repository
        ↓
./Scripts/bootstrap.sh
        ↓
Open generated .xcodeproj
        ↓
Configure Development Team if required
        ↓
Review local secrets
        ↓
Build
        ↓
Run
        ↓
Tests
        ↓
Start implementing features
```

The template should remain a starting point, not a framework that every
application is forced to adopt completely.

---

## Documentation

For a detailed architecture description, see:

[Documentation/Architecture.md](Documentation/Architecture.md)

---

## License

This project is available under the MIT License.

See the [LICENSE](LICENSE) file for details.
