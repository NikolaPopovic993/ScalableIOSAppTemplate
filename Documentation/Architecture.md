# Architecture

This template uses a pragmatic feature-first architecture designed for iOS
applications that are expected to grow over time.

The architecture combines:

```text
Feature-first modularization
Clean Architecture principles
MVVM where presentation state requires it
Initializer-based dependency injection
Composition Root
Swift Package Manager target boundaries
```

The goal is not to force every feature into the same structure.

The goal is to provide clear dependency boundaries that can be introduced when
they are useful.

---

## Architecture Goals

The template is designed around several principles:

```text
Features own their implementation
Dependencies remain explicit
Business logic stays independent from UI and infrastructure
Modules can be tested independently
The application owns top-level composition
Shared code has clear ownership
Features can start small and grow over time
```

The architecture optimizes for:

```text
Maintainability
Testability
Scalability
Clear ownership
Dependency control
Compiler-enforced boundaries
```

It intentionally accepts some additional project structure in exchange for
those benefits.

---

## High-Level Structure

The project is organized approximately as:

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
│   └── Environments/
│       ├── Development.xcconfig
│       └── Production.xcconfig
├── Documentation/
├── Scripts/
└── .github/
```

Responsibilities are divided between:

```text
Application
    ↓
Features
    ↓
Shared application modules
    ↓
Reusable external packages
```

---

# Application Layer

The application target is the top-level composition layer.

It owns application-specific concerns such as:

```text
Application entry point
Root navigation
Application lifecycle
Global configuration
Composition Root
Feature assembly
Application-wide state
```

The host application should contain as little feature-specific business logic as
possible.

Its primary responsibility is to connect independently defined modules.

---

## Application Configuration

Application-wide runtime configuration lives under:

```text
App/Configuration/
```

The template keeps Xcode build configurations separate from application
environments. Environment-specific values are provided through `.xcconfig`
files under `Config/Environments/` and exposed to Swift through
`AppConfiguration`.

Configuration is infrastructure and application composition concern; feature
business logic should not depend directly on environment names.

See [Configuration](Configuration.md) for details.

---

## App Entry

The SwiftUI application entry point lives under:

```text
App/AppEntry/
```

For example:

```text
ScalableIOSAppTemplateApp.swift
```

Its responsibility should remain small.

Conceptually:

```text
App Entry
    ↓
AppContainer
    ↓
RootView
```

The App Entry creates the application-level dependencies and starts the root UI.

---

## Composition Root

Application-level dependency composition lives under:

```text
App/Composition/
```

The central object is typically:

```text
AppContainer
```

The Composition Root is the location where concrete implementations are created
and connected.

For example:

```text
AppContainer
├── NetworkClient
├── Feature dependencies
├── Feature assemblies
└── Application configuration
```

Dependencies should generally be created at the highest appropriate level and
passed downward through initializers.

This makes ownership explicit and avoids hidden global dependencies.

---

## Dependency Injection

The preferred dependency injection style is:

```text
Initializer Injection
```

For example:

```swift
final class ProfileViewModel {

    private let loadProfile: LoadProfileUseCase

    init(
        loadProfile: LoadProfileUseCase
    ) {
        self.loadProfile = loadProfile
    }
}
```

The template intentionally avoids using global singletons as the primary
dependency injection mechanism.

SwiftUI Environment may still be useful for presentation-level concerns, but it
should not become the default service locator for repositories, networking, or
business services.

---

# FeaturesPackage

Feature-specific code lives inside:

```text
Packages/FeaturesPackage/
```

The physical organization is feature-first.

For example:

```text
FeaturesPackage/
├── Sources/
│   ├── Authentication/
│   │   ├── Domain/
│   │   ├── Data/
│   │   ├── Interface/
│   │   └── Assembly/
│   │
│   └── About/
│       └── Interface/
│
└── Tests/
    └── Authentication/
        ├── DomainTests/
        └── DataTests/
```

The physical directory hierarchy is organized by feature, while Swift Package
Manager still creates separate compiler targets.

For example:

```text
Authentication/
├── Domain/
├── Data/
├── Interface/
└── Assembly/
```

becomes:

```text
AuthenticationDomain
AuthenticationData
AuthenticationInterface
AuthenticationAssembly
```

This gives the project both:

```text
Feature-oriented navigation for developers
+
Compiler-enforced module boundaries
```

---

# Package vs Target

`FeaturesPackage` is one Swift Package.

Individual architectural modules are SwiftPM targets inside that package.

For example:

```text
FeaturesPackage
│
├── AuthenticationDomain
├── AuthenticationData
├── AuthenticationInterface
├── AuthenticationAssembly
│
├── AboutInterface
│
└── BackgroundSyncData
```

A separate Swift package is not required for every feature.

Targets are usually sufficient for compiler boundaries while keeping package
management manageable.

A feature should be extracted into its own package or repository only when
there is a real reason, such as:

```text
Independent ownership
Independent release cycle
Reuse across applications
Different versioning requirements
Separate team responsibility
```

---

# Flexible Feature Composition

A feature does not need to contain:

```text
Domain
Data
Interface
Assembly
```

all at once.

These are available architectural boundaries, not mandatory layers.

A feature should include only the modules that provide useful separation.

---

## Full Feature

A complex feature may use all modules:

```text
Authentication
├── Domain
├── Data
├── Interface
└── Assembly
```

This is useful when a feature contains:

```text
Business rules
Remote/local data access
Presentation
Dependency composition
```

---

## Interface-only Feature

A simple informational screen may need only:

```text
About
└── Interface
```

There is no architectural value in creating empty Domain, Data, or Assembly
modules when they have no responsibility.

---

## Domain + Interface

A feature with business logic but no external data source may use:

```text
Calculator
├── Domain
└── Interface
```

The dependency direction becomes:

```text
CalculatorInterface
        ↓
CalculatorDomain
```

---

## Background Feature

A feature without UI may use:

```text
BackgroundSync
├── Domain
├── Data
└── Assembly
```

This is useful for:

```text
Background processing
Synchronization
Capability modules
Infrastructure-driven features
```

There is no requirement for a SwiftUI Interface module.

---

## Data-only Capability

A small capability may contain only:

```text
ImageCache
└── Data
```

This can be appropriate when the module exists primarily to provide an
infrastructure capability and there is no meaningful independent Domain model.

---

# Feature Modules

The available module types are:

```text
Domain
Data
Interface
Assembly
```

Each has a specific responsibility.

---

# Domain

The Domain module contains business concepts and rules.

Typical contents include:

```text
Domain models
Business rules
Repository protocols
Use case protocols or implementations
Validation rules
Feature-specific abstractions
```

Domain should not depend on:

```text
SwiftUI
UIKit
URLSession
CoreNetworking
Database implementations
Feature Interface
Feature Data
```

Conceptually:

```text
Domain
    ↓
Foundation-level language constructs only
```

The Domain should remain independently testable.

---

## Repository Protocols

When a feature requires data access but the business layer should remain
independent from infrastructure, repository contracts typically belong in
Domain.

For example:

```swift
public protocol ProfileRepository {
    func loadProfile() async throws -> Profile
}
```

The concrete implementation belongs in Data.

Conceptually:

```text
Domain
    ↓ defines
ProfileRepository

Data
    ↓ implements
RemoteProfileRepository
```

This is Dependency Inversion.

---

## Use Cases

Use cases are useful when they represent meaningful application or business
operations.

For example:

```text
AuthenticateUser
LoadProfile
SubmitOrder
ValidateRegistration
RefreshSession
```

A use case does not need to exist only because the architecture contains a
Domain layer.

If a use case would only forward one method with no meaningful business or
orchestration responsibility:

```text
ViewModel
    ↓
UseCase
    ↓
Repository
```

it may become unnecessary indirection.

The architecture is intentionally pragmatic.

Use a use case when it provides value such as:

```text
Business rules
Validation
Orchestration
Multiple repository calls
Authorization decisions
Transformation
Reusable domain operation
```

Avoid creating layers only to satisfy a diagram.

---

# Data

The Data module contains infrastructure implementations.

Typical responsibilities include:

```text
Repository implementations
DTOs
Remote data sources
Local persistence
Mappers
Networking integration
Caching
Storage adapters
```

Data may depend on Domain:

```text
Data
    ↓
Domain
```

because it implements contracts defined by the business layer.

Domain must not depend on Data.

---

## DTO Mapping

Network DTOs should generally remain in Data.

For example:

```text
API Response
    ↓
ProfileDTO
    ↓
ProfileMapper
    ↓
Profile
```

where:

```text
ProfileDTO
→ Data

ProfileMapper
→ Data

Profile
→ Domain
```

This prevents backend response structures from becoming the application's
business model.

---

## CoreNetworking

`CoreNetworking` is treated as reusable infrastructure.

When a feature enables networking:

```swift
usesNetworking: true
```

the feature configuration can provide `CoreNetworking` to supported
infrastructure modules.

Conceptually:

```text
FeatureData
├── FeatureDomain
└── CoreNetworking
```

and, when appropriate:

```text
FeatureAssembly
└── CoreNetworking
```

`CoreNetworking` is not automatically exposed to Domain or Interface.

This keeps networking concerns outside the business and presentation layers.

---

# Interface

The Interface module contains presentation-level functionality.

Typical contents include:

```text
SwiftUI Views
ViewModels
Presentation models
Feature navigation
Feature-level flows
Screen state
UI interaction logic
```

Interface may depend on Domain:

```text
Interface
    ↓
Domain
```

It should not normally depend directly on Data.

Avoid:

```text
Interface
    ↓
Data
```

because presentation should depend on abstractions and business concepts rather
than concrete infrastructure implementations.

---

## MVVM

The template supports MVVM where a ViewModel provides useful separation.

For example:

```text
SwiftUI View
    ↓
ViewModel
    ↓
Domain operation
```

A ViewModel is useful when it owns:

```text
Screen state
Async loading
User actions
Presentation transformations
Error/loading/success state
Coordination between multiple operations
```

A ViewModel is not mandatory for every SwiftUI View.

A small, purely visual component may not need one.

The goal is separation of responsibilities, not one ViewModel per file.

---

# Assembly

Assembly is the feature-level composition layer.

It connects concrete feature dependencies.

Conceptually:

```text
Assembly
├── Domain
├── Data
└── Interface
```

depending on which modules actually exist.

For example:

```swift
public enum AuthenticationAssembly {

    public static func makeView(
        networkClient: NetworkClient
    ) -> some View {
        // Create repository
        // Create use case
        // Create view model
        // Create view
    }
}
```

Assembly is useful when a feature needs non-trivial dependency wiring.

It is not mandatory.

For a simple feature:

```text
About
└── Interface
```

creating:

```text
AboutAssembly
```

only to return:

```swift
AboutView()
```

would add little value.

---

# Dependency Direction

For a full feature, the intended dependency direction is approximately:

```text
        Assembly
       /   |    \
      ↓    ↓     ↓
   Domain Data Interface
      ↑      ↑
      └──────┘
```

A clearer representation is:

```text
Domain

Data
└── Domain

Interface
└── Domain

Assembly
├── Domain
├── Data
└── Interface
```

The important rules are:

```text
Domain does not depend on Data
Domain does not depend on Interface
Data does not depend on Interface
Interface does not depend on Data
Assembly may compose the available modules
```

If a module does not exist, its dependency does not exist either.

---

# FeatureConfiguration

Features are declared inside:

```text
Packages/FeaturesPackage/Package.swift
```

using `FeatureConfiguration`.

Example:

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

The configuration describes:

```text
Which modules exist
Whether networking infrastructure is required
Whether supported tests should be created
Additional dependencies for each module
```

Available custom dependency groups are:

```swift
domainDependencies
dataDependencies
interfaceDependencies
assemblyDependencies
```

This avoids adding configuration flags for every possible dependency.

---

# Explicit Dependencies

Dependencies should be added to the module that actually requires them.

For example:

```swift
interfaceDependencies: [
    .product(
        name: "SharedUI",
        package: "SharedPackage"
    )
]
```

means:

```text
FeatureInterface
    ↓
SharedUI
```

while:

```swift
dataDependencies: [
    .product(
        name: "SharedUtilities",
        package: "SharedPackage"
    )
]
```

means:

```text
FeatureData
    ↓
SharedUtilities
```

Avoid giving all feature modules access to a dependency simply because one
module uses it.

---

# SharedPackage

Application-specific reusable code lives inside:

```text
Packages/SharedPackage/
```

Typical modules include:

```text
SharedUI
SharedUtilities
```

The SharedPackage is intended for functionality that:

```text
belongs to this application
and
is genuinely shared between multiple features
```

---

## SharedUI

`SharedUI` may contain reusable application UI components such as:

```text
Buttons
Cards
Loading states
Error states
Typography helpers
Application-specific visual components
```

Feature Interface modules can explicitly depend on `SharedUI` when required.

Example:

```swift
interfaceDependencies: [
    .product(
        name: "SharedUI",
        package: "SharedPackage"
    )
]
```

`SharedUI` should not become a location for feature-specific screens.

---

## SharedUtilities

`SharedUtilities` may contain application-specific utilities reused by multiple
features.

Examples may include:

```text
Formatting helpers
Small app-specific helpers
Reusable non-business utilities
```

A utility used by only one feature should normally remain inside that feature.

---

# Where Shared Code Belongs

Use the following rule:

```text
Used by one feature
→ keep inside the feature

App-specific and used by multiple features
→ SharedPackage

Generic and reusable across applications
→ separate reusable Swift package
```

For example:

```text
Authentication-only validator
→ Authentication

Application-specific status view used by many features
→ SharedUI

Generic networking library
→ CoreNetworking remote package
```

This prevents `SharedPackage` from becoming a dumping ground.

---

# Shared Business Concepts

Not every shared concept belongs in `SharedUtilities`.

If multiple features depend on the same real business concept, consider
introducing a dedicated business module.

For example:

```text
Profile
Settings
Orders
```

may all require a shared user concept.

Instead of placing:

```text
User
UserRepository
UserEndpoints
```

inside a generic utilities module, a dedicated module may be more appropriate:

```text
UserDomain
UserData
```

The deciding factor is ownership and business meaning, not the number of files.

---

# Local vs Remote Packages

The project distinguishes between application modules and reusable libraries.

Use local packages for code owned by the application:

```text
FeaturesPackage
SharedPackage
```

Use remote packages for generic libraries reusable across applications:

```text
CoreNetworking
CoreValidation
CoreAnalytics
CoreLogging
```

A generic library should not depend on application-specific features.

---

# Cross-Feature Dependencies

Direct feature-to-feature dependencies should be introduced carefully.

Avoid casually creating:

```text
ProfileInterface
    ↓
AuthenticationInterface
```

or:

```text
SettingsData
    ↓
ProfileData
```

because this can gradually create a tightly coupled feature graph.

Prefer communication through:

```text
Application state
Shared business modules
Protocols
Application-level navigation
Explicit domain abstractions
```

---

## Cross-Feature Navigation

Top-level navigation between independent features should normally be owned by
the application.

For example:

```text
Authentication
    ↓ event
Application / Root Navigation
    ↓
Home
```

instead of:

```text
Authentication
    ↓ directly constructs
Home
```

A feature may own navigation inside its own flow, but the application owns
transitions between major application areas.

---

# Navigation

The application may use SwiftUI:

```text
NavigationStack
NavigationPath
Feature-level flow objects
Coordinator-like abstractions
```

A feature can own internal routes while the host application owns the root
navigation state.

Conceptually:

```text
RootView
├── Authentication Flow
├── Main Flow
└── Settings Flow
```

Feature navigation should not require unrelated features to import one another.

---

# Using Feature Products from the Application

Adding a feature to `FeaturesPackage` does not automatically make the
application target depend on it.

The application should explicitly add the product it uses.

For example:

```text
About
└── AboutInterface
```

The application target can depend on:

```text
AboutInterface
```

and then:

```swift
import AboutInterface
```

A complex feature may instead expose:

```text
AuthenticationAssembly
```

and the application can depend on that product.

This keeps the host target's dependencies explicit.

---

# Feature Growth

A feature does not need to predict its final architecture when it is created.

For example, it may start as:

```text
Profile
├── Domain
└── Data
```

Later UI may be introduced:

```text
Profile
├── Domain
├── Data
└── Interface
```

Later dependency composition may become complex enough to justify:

```text
Profile
├── Domain
├── Data
├── Interface
└── Assembly
```

The architecture supports incremental growth.

Adding a module later requires:

```text
Create its source directory
Add the module to FeatureConfiguration
Add any required explicit dependencies
```

The generator defines the initial shape, not the permanent shape.

---

# Testing

Tests should generally follow module responsibilities.

The default feature configuration supports:

```text
DomainTests
DataTests
```

when their corresponding modules exist.

For example:

```text
Feature
├── Domain
└── Interface
```

with tests enabled creates:

```text
FeatureDomainTests
```

but not:

```text
FeatureDataTests
```

because Data does not exist.

---

## Domain Tests

Domain tests should focus on:

```text
Business rules
Use cases
Validation
Domain transformations
Business decisions
```

They should require minimal infrastructure.

---

## Data Tests

Data tests may focus on:

```text
Repository implementations
DTO mapping
Persistence adapters
Networking behavior
Caching behavior
```

Infrastructure dependencies should be mocked or controlled where appropriate.

---

## Interface Tests

Interface test targets are not automatically generated by the feature
generator.

Presentation logic can still be tested when useful.

For example:

```text
ViewModel tests
State transition tests
Presentation mapper tests
```

Projects may introduce dedicated Interface test targets when needed.

---

# Continuous Integration

Pull requests targeting `main` are validated with GitHub Actions.

The standard CI pipeline verifies:

```text
Shell script syntax
SharedPackage manifest
FeaturesPackage manifest
iOS application build
Configured test suite
```

See:

```text
Documentation/CI.md
```

for details.

CI intentionally focuses on pull request validation.

Application deployment and signing remain project-specific concerns.

---

# Architectural Trade-offs

This architecture provides stronger boundaries, but those boundaries have a
cost.

Benefits include:

```text
Compiler-enforced dependencies
Clear ownership
Improved testability
Smaller feature responsibility
Easier replacement of infrastructure
Better scalability for larger teams
```

Costs include:

```text
More targets
More Package.swift configuration
More initial project structure
Longer onboarding for developers unfamiliar with modular architecture
Potential build graph complexity
```

The template is therefore optimized for applications where maintainability and
growth matter more than minimum initial setup.

For a very small prototype, this structure may be more than necessary.

---

# Avoiding Over-Architecture

The template intentionally supports smaller feature shapes because modular
architecture can easily become excessive.

Avoid creating:

```text
Empty Domain modules
Empty Data modules
Assembly modules that only return a View
Use cases that only forward one repository call
Protocols that have no abstraction value
Shared modules used by one feature
```

Create architectural boundaries when they provide:

```text
Testability
Dependency inversion
Business separation
Independent evolution
Clear ownership
Reusable application behavior
```

Architecture should reduce complexity, not move it into more files.

---

# Example: Authentication

Authentication is intentionally a full feature because it demonstrates the
complete dependency structure.

Conceptually:

```text
Authentication
├── Domain
│   ├── Models
│   ├── Repository contracts
│   └── Use cases
│
├── Data
│   ├── DTOs
│   ├── Mappers
│   ├── Repository implementations
│   └── Networking
│
├── Interface
│   ├── Views
│   ├── ViewModels
│   └── Presentation state
│
└── Assembly
    └── Dependency composition
```

The important point is not that every future feature should look like
Authentication.

Authentication exists as a reference implementation for a feature that
actually benefits from all architectural modules.

---

# Guiding Principles

When adding new code, ask:

```text
Who owns this code?
```

Then:

```text
Does only one feature use it?
→ Keep it in that feature.

Do multiple application features use it?
→ Consider SharedPackage or a dedicated shared business module.

Is it generic across applications?
→ Consider a reusable remote Swift package.
```

When creating a feature, ask:

```text
Does it contain business rules?
→ Consider Domain.

Does it require remote/local infrastructure?
→ Consider Data.

Does it expose UI?
→ Consider Interface.

Does dependency composition require a dedicated boundary?
→ Consider Assembly.
```

Do not add modules only because they are available.

---

# Summary

The architecture can be summarized as:

```text
Application
│
├── Composition Root
├── Root Navigation
└── Configuration
        │
        ▼
FeaturesPackage
│
├── Feature A
│   ├── Domain
│   ├── Data
│   ├── Interface
│   └── Assembly
│
├── Feature B
│   └── Interface
│
└── Feature C
    ├── Domain
    ├── Data
    └── Assembly
        │
        ▼
SharedPackage
│
├── SharedUI
└── SharedUtilities
        │
        ▼
Reusable Packages
│
└── CoreNetworking
```

The central rule is:

> Use the smallest set of architectural boundaries that keeps the feature
> understandable, testable, and maintainable.

Features are allowed to evolve as their responsibilities grow.
