# Architecture

This document describes the architectural rules and scaling strategy used by
the Scalable iOS App Template.

The architecture combines:

- Feature-first modularization
- Pragmatic Clean Architecture
- MVVM presentation
- Swift Package Manager
- Initializer-based dependency injection
- Explicit composition roots

The primary goal is to preserve clear ownership and dependency boundaries
without introducing unnecessary complexity.

---

## High-Level Structure

The application is divided into three main areas:

```text
Application
SharedPackage
FeaturesPackage
```

### Application

The host application owns:

```text
Application lifecycle
Application configuration
Root navigation
Global dependency composition
Feature integration
```

### SharedPackage

Contains application-specific code that is genuinely shared between multiple
features.

### FeaturesPackage

Contains independently compiled application features.

---

## Feature-First Organization

Features are physically organized by feature:

```text
FeaturesPackage/
└── Sources/
    ├── Authentication/
    │   ├── Domain/
    │   ├── Data/
    │   ├── Interface/
    │   └── Assembly/
    │
    ├── Profile/
    │   ├── Domain/
    │   ├── Data/
    │   ├── Interface/
    │   └── Assembly/
    │
    └── Payments/
        ├── Domain/
        ├── Data/
        ├── Interface/
        └── Assembly/
```

The physical directory structure is feature-first, but each layer remains a
separate Swift target.

For example:

```text
ProfileDomain
ProfileData
ProfileInterface
ProfileAssembly
```

This provides:

```text
Readable feature ownership
+
Compiler-enforced module boundaries
```

---

## Package vs Target

A Swift Package is primarily a container.

Swift targets define compiler boundaries.

For example, both Authentication and Profile may live inside:

```text
FeaturesPackage
```

without being able to access each other's implementation.

`ProfileInterface` cannot import:

```text
AuthenticationData
```

unless that dependency is explicitly declared.

Therefore:

```text
Same Package ≠ Same Module
```

A separate Swift Package per feature is not required by default.

---

# Feature Layers

## Domain

Domain contains business-facing abstractions and rules.

Typical responsibilities:

```text
Domain models
Repository protocols
Use cases
Business rules
Domain errors
Validation rules
```

Domain must not depend on:

```text
Data
Interface
SwiftUI
CoreNetworking
Concrete persistence
Concrete infrastructure
```

Domain should remain the most stable feature layer.

---

## Data

Data contains implementations required to satisfy Domain abstractions.

Typical responsibilities:

```text
DTOs
Endpoints
Mappers
Repository implementations
Remote data sources
Persistence adapters
```

Typical dependency:

```text
ProfileData
    ↓
ProfileDomain
```

If networking is required:

```text
ProfileData
    ↓
CoreNetworking
```

Data must not depend on Interface.

---

## Interface

Interface contains presentation logic.

Typical responsibilities:

```text
SwiftUI Views
ViewModels
Presentation state
UI-specific models
```

Typical dependency:

```text
ProfileInterface
    ↓
ProfileDomain
```

If shared application UI components are required:

```text
ProfileInterface
    ↓
SharedUI
```

Interface should not depend directly on:

```text
ProfileData
CoreNetworking
```

---

## Assembly

Assembly is the feature-level Composition Root.

It constructs feature dependencies.

Conceptually:

```text
Repository
    ↓
UseCase
    ↓
ViewModel
    ↓
View
```

Assembly may depend on:

```text
Domain
Data
Interface
Required infrastructure
```

The host application should normally interact with a feature through its
Assembly instead of constructing every feature dependency itself.

---

# Dependency Direction

Default dependency direction:

```text
Domain
↑
Data

Domain
↑
Interface

Domain + Data + Interface
↑
Assembly
```

Dependencies should point toward Domain.

A simple model:

```text
                    Assembly
                  /    |    \
                 ▼     ▼     ▼
              Domain  Data  Interface
                ▲      │       │
                └──────┘       │
                ▲              │
                └──────────────┘
```

---

# Application Composition Root

Application-wide dependencies are constructed in:

```text
AppContainer
```

Typical responsibilities include:

```text
NetworkClient creation
Application configuration
Feature builders
Global services
Session-level services
```

Example:

```text
AppContainer
    ↓
AuthenticationFeatureBuilder
    ↓
AuthenticationAssembly
```

This keeps concrete dependency creation close to the application boundary.

---

# Feature Manifest

Feature target configuration is centralized in:

```text
Packages/FeaturesPackage/Package.swift
```

Example:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true
)
```

The helper generates:

```text
ProfileDomain
ProfileData
ProfileInterface
ProfileAssembly
ProfileDomainTests
ProfileDataTests
```

and maps them to:

```text
Sources/Profile/Domain
Sources/Profile/Data
Sources/Profile/Interface
Sources/Profile/Assembly

Tests/Profile/DomainTests
Tests/Profile/DataTests
```

This prevents the package manifest from becoming dominated by repetitive
target declarations.

---

# SharedPackage

`SharedPackage` exists for application-specific code that is genuinely shared
across feature boundaries.

Current examples:

```text
SharedUI
SharedUtilities
```

The package should remain intentionally small.

Avoid using SharedPackage as:

```text
Helpers
Common
Everything
Misc
```

A type should have a clear reason to be shared.

---

## SharedUI

`SharedUI` may contain the application's reusable design-system components.

Examples:

```text
AppButton
AppCard
AppTextField
AppLoadingView
AppTypography
Spacing
Reusable state views
```

A feature should only depend on SharedUI when it uses these components.

That dependency is controlled through:

```swift
usesSharedUI: true
```

---

## SharedUtilities

`SharedUtilities` contains small application-wide utilities that are genuinely
shared between modules.

Feature-specific utilities should remain inside their feature.

Do not move code into SharedUtilities only to avoid deciding which feature
owns it.

---

# Shared Business Concepts

Code should not become shared merely because it is used by several screens.

For example:

```text
ProfileScreen
EditProfileScreen
ProfileDetailsScreen
```

may all use:

```text
GET /profile
```

The endpoint still belongs to:

```text
Profile/Data
```

because all consumers belong to the same feature.

---

## Cross-Feature Business Capabilities

A shared business module may make sense when independent features depend on the
same business capability.

Example:

```text
Profile
Orders
Payments
    ↓
Current User
```

A future shared module might be:

```text
SharedPackage/
└── User/
    ├── Domain/
    └── Data/
```

Features should preferably depend on the shared business abstraction:

```text
ProfileDomain
    ↓
UserDomain
```

rather than infrastructure details such as:

```text
GetCurrentUserEndpoint
```

Endpoints are implementation details.

Business capabilities make better architectural boundaries.

Shared business modules should only be introduced when the requirement
actually appears.

---

# Local vs Remote Packages

Use this guideline:

```text
Used by one feature
        ↓
Keep inside the feature

Application-specific and shared by multiple features
        ↓
SharedPackage

Generic and reusable across applications
        ↓
Separate repository + remote Swift Package
```

Examples:

```text
Profile endpoint
→ Profile/Data

Application design system
→ SharedUI

Application-specific Session
→ SharedPackage when genuinely shared

Generic networking
→ CoreNetworking remote package

Generic validation
→ External reusable package when appropriate
```

---

# Cross-Feature Dependencies

Avoid implementation dependencies such as:

```text
ProfileData
    ↓
AuthenticationData
```

or:

```text
ProfileInterface
    ↓
PaymentsInterface
```

If several features require the same concept, evaluate whether that concept
should have an explicit shared abstraction.

Cross-feature dependencies should be intentional, not accidental.

---

# Cross-Feature Navigation

Features should not directly own application-level navigation into unrelated
features.

Avoid:

```text
Profile
    ↓
AuthenticationView
```

Prefer:

```text
Profile
    ↓
Logout requested
    ↓
Application state
    ↓
Root navigation
    ↓
Authentication flow
```

Application-level navigation belongs to the host Application layer.

---

# Repositories and Use Cases

Not every feature automatically needs:

```text
Repository
UseCase
ViewModel
```

These abstractions should be introduced when they provide a real boundary or
business responsibility.

A simple feature may initially require only:

```text
View
State
```

A data-driven feature may later introduce:

```text
Repository protocol
Repository implementation
Use case
ViewModel
```

The architecture is intentionally pragmatic.

Avoid creating middle layers purely for architectural symmetry.

---

# Feature Growth

A feature starts inside `FeaturesPackage`:

```text
Sources/Profile/
├── Domain/
├── Data/
├── Interface/
└── Assembly/
```

If the feature later becomes large enough to justify stronger physical
isolation, it can be extracted into a dedicated Swift Package.

Reasons may include:

```text
Independent team ownership
Cross-application reuse
Separate repository ownership
Independent release lifecycle
Build isolation requirements
```

The feature-first directory structure makes later extraction easier.

Separate packages should be introduced because there is a requirement, not
because a feature might become large someday.

---

# Testing

Domain tests verify business behavior.

Data tests verify responsibilities such as:

```text
DTO mapping
Endpoint configuration
Repository behavior
Interaction with infrastructure abstractions
```

Do not re-test implementation details owned by external packages.

For example, a feature Data test does not need to verify generic `URLSession`
behavior when that responsibility belongs to CoreNetworking.

---

# Guiding Principles

The architecture favors:

```text
Explicit dependencies
Clear ownership
Feature-first organization
Compiler-enforced boundaries
Initializer injection
Small shared surface area
Composition at boundaries
Testability
Incremental scaling
```

The architecture should evolve with the application.

Do not introduce abstractions, packages, or shared modules until they provide
concrete value.
