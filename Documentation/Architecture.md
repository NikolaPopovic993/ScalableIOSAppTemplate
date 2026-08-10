# Architecture

This project is a scalable iOS application template built around explicit
module boundaries, initializer-based dependency injection, and a pragmatic
Clean Architecture approach.

The goal is not to introduce layers for their own sake, but to provide a
structure that can grow with the application while keeping dependencies
predictable and testable.

---

## Overview

The application is organized into three main areas:

```text
App
│
├── Application composition
├── Runtime configuration
└── Root navigation

Packages
│
├── CorePackage
└── FeaturesPackage

External Dependencies
└── CoreNetworking
```

The host application acts as the top-level composition root.

Feature implementation lives inside `FeaturesPackage`, while reusable
application-independent primitives live inside `CorePackage`.

---

## High-Level Dependency Graph

```text
┌─────────────────────────────┐
│         Application         │
│                             │
│ AppContainer                │
│ RootView                    │
│ AppConfiguration            │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       Feature Assembly      │
└────────┬───────────┬────────┘
         │           │
         ▼           ▼
   Interface        Data
         │           │
         ▼           │
       Domain ◄──────┘
                     │
                     ▼
               Infrastructure
               / External SDKs
```

Dependencies always point inward toward the Domain layer.

The Domain layer never depends on Data, Interface, networking frameworks,
persistence frameworks, or UI frameworks.

---

# Packages and Modules

A Swift Package is used as a container for related modules.

A package does not necessarily represent a single architectural module.

For example:

```text
FeaturesPackage
│
├── AuthenticationDomain
├── AuthenticationData
├── AuthenticationInterface
└── AuthenticationAssembly
```

`FeaturesPackage` is the package.

Each entry inside it is a separate Swift target and therefore a separate
Swift module.

This allows dependency rules to be enforced by the compiler without
requiring one `Package.swift` file for every feature.

---

# CorePackage

`CorePackage` contains reusable functionality that is not owned by a
specific feature.

Current modules:

```text
CorePackage
├── CoreDomain
├── CoreUI
└── CoreUtilities
```

## CoreDomain

Contains small domain primitives that are genuinely shared across multiple
features.

It should not become a dumping ground for feature-specific business models.

Good candidates:

```text
Identifiers
Shared value types
Cross-feature domain primitives
```

Feature-specific models should remain inside their feature domain.

## CoreUI

Contains reusable UI components shared by multiple features.

Examples:

```text
Loading views
Reusable state views
Common visual components
```

`CoreUI` may depend on SwiftUI.

It must not contain feature-specific screens or business logic.

## CoreUtilities

Contains small generic utilities that are reusable across the application.

Utilities should remain focused and should not become a generic `Helpers`
folder.

---

# FeaturesPackage

Application features live inside `FeaturesPackage`.

A feature is normally split into four modules:

```text
FeatureDomain
FeatureData
FeatureInterface
FeatureAssembly
```

For example:

```text
AuthenticationDomain
AuthenticationData
AuthenticationInterface
AuthenticationAssembly
```

Each module has a specific responsibility.

---

# Domain

The Domain module contains business concepts and contracts.

Example:

```text
AuthenticationDomain
├── Models
├── Errors
├── Repositories
└── UseCases
```

Typical types include:

```text
Entities
Value types
Repository protocols
Use cases
Business validation
Domain errors
```

The Domain module must remain independent from implementation details.

It must not import:

```text
SwiftUI
CoreNetworking
URLSession
AuthenticationData
AuthenticationInterface
```

Example:

```swift
public protocol AuthenticationRepository: Sendable {
    func login(
        credentials: LoginCredentials
    ) async throws -> AuthenticationSession
}
```

The Domain layer knows that authentication must be performed, but it does
not know how authentication is implemented.

---

# Data

The Data module implements Domain contracts using external systems.

Example:

```text
AuthenticationData
├── DTOs
├── Endpoints
├── Mappers
└── Repositories
```

The Data layer may depend on:

```text
FeatureDomain
CoreNetworking
Persistence
External SDKs
```

It must not depend on the Interface layer.

Example:

```swift
public final class DefaultAuthenticationRepository:
    AuthenticationRepository {

    private let networkClient: any NetworkClient

    public init(
        networkClient: any NetworkClient
    ) {
        self.networkClient = networkClient
    }
}
```

The repository implementation belongs to Data because it knows how Domain
requirements are fulfilled.

---

# DTOs and Domain Models

DTOs represent external contracts.

Domain models represent application business concepts.

They should not automatically be treated as the same model.

Example:

```text
Backend JSON
    ↓
LoginResponseDTO
    ↓
Mapper
    ↓
AuthenticationSession
```

Keeping DTOs inside Data prevents backend changes from leaking directly into
the Domain and UI layers.

---

# Interface

The Interface module contains presentation logic.

Example:

```text
AuthenticationInterface
├── State
├── ViewModels
└── Views
```

It may depend on:

```text
FeatureDomain
CoreUI
SwiftUI
```

It should not depend on:

```text
FeatureData
CoreNetworking
URLSession
```

A ViewModel talks to Domain abstractions such as use cases.

Example:

```text
LoginView
    ↓
LoginViewModel
    ↓
LoginUseCase
```

Not:

```text
LoginViewModel
    ↓
NetworkClient
```

This keeps presentation independent from infrastructure.

---

# Feature Assembly

The Assembly module is the composition root of a feature.

Example:

```text
AuthenticationAssembly
└── AuthenticationFeatureBuilder
```

It is allowed to know about all layers of its feature because its purpose is
to construct the dependency graph.

Example:

```text
AuthenticationFeatureBuilder
        │
        ├── Repository
        ├── UseCase
        ├── ViewModel
        └── View
```

The Application layer does not need to know these internal implementation
details.

Instead of:

```text
AppContainer
├── DefaultAuthenticationRepository
├── DefaultLoginUseCase
├── LoginViewModel
└── LoginView
```

we prefer:

```text
AppContainer
    ↓
AuthenticationFeatureBuilder
```

This prevents the application composition root from becoming tightly coupled
to every implementation detail inside every feature.

---

# Application Composition Root

The host application owns global dependency construction.

Current location:

```text
ScalableIOSAppTemplate/
└── App/
    └── Composition/
        └── AppContainer.swift
```

Examples of dependencies that may be created here:

```text
Network client
Session controller
Analytics client
Persistence stack
Feature builders
```

Dependencies are passed through initializers rather than accessed through
global singletons.

Example:

```swift
let authenticationBuilder =
    AuthenticationFeatureBuilder(
        networkClient: networkClient
    )
```

This makes ownership explicit and allows implementations to be replaced in
tests or application variants.

---

# Networking

Networking is intentionally implemented as an independent Swift Package
dependency.

The template currently uses:

```text
CoreNetworking
```

Feature Data modules depend on the `NetworkClient` abstraction exposed by
CoreNetworking.

Example:

```text
AuthenticationData
        ↓
NetworkClient
        ↓
CoreNetworking implementation
```

The Domain and Interface layers do not know that CoreNetworking exists.

This means the networking implementation can be replaced without changing
business or presentation code.

---

# Adding a New Feature

A new feature should normally add four targets to `FeaturesPackage`.

For example:

```text
ProfileDomain
ProfileData
ProfileInterface
ProfileAssembly
```

Recommended dependency direction:

```text
ProfileInterface
       │
       ▼
 ProfileDomain
       ▲
       │
  ProfileData
       │
       ▼
External Infrastructure
```

And:

```text
ProfileAssembly
├── ProfileDomain
├── ProfileData
└── ProfileInterface
```

The new targets must also be declared explicitly in
`FeaturesPackage/Package.swift`.

Only add dependencies that a target actually needs.

For example, if `ProfileData` uses CoreNetworking:

```text
ProfileData → CoreNetworking
```

but there is no reason for:

```text
ProfileDomain → CoreNetworking
```

---

# Shared Domain Concepts

Some business concepts may be used by multiple features.

Examples:

```text
User
Session
Account
Permissions
```

Do not immediately move every shared-looking type into `CoreDomain`.

If a concept becomes an important cross-feature business model, prefer a
dedicated shared domain module such as:

```text
UserDomain
SessionDomain
```

Example:

```text
AuthenticationDomain ──┐
ProfileDomain ──────────┼──► UserDomain
HomeDomain ─────────────┘
```

This prevents `CoreDomain` from becoming a large collection of unrelated
business models.

Also consider whether different features really need the same complete
model.

For example:

```text
Profile → UserProfile
Home    → UserSummary
Auth    → AuthenticatedUser
```

These may legitimately be different representations of the same underlying
user concept.

---

# Cross-Feature Navigation

Features should avoid navigating directly to other features.

Avoid:

```text
ProfileFeature
    ↓
AuthenticationFeature
```

A feature should communicate events or state changes to the application
layer.

For example, logout should conceptually look like:

```text
Profile
    ↓
Logout requested
    ↓
Session state changes
    ↓
Application flow
    ↓
Authentication flow
```

The Profile feature should not construct or navigate directly to
`LoginView`.

Root navigation belongs to the application layer.

This allows flows such as:

```text
Authentication
Main
Onboarding
Forced Update
Maintenance
```

to remain application concerns rather than feature dependencies.

---

# Session State

When session handling is required, shared session models may live inside a
dedicated `SessionDomain` module.

For example:

```swift
public enum SessionState: Sendable {
    case unauthenticated
    case authenticated(UserSession)
}
```

The mutable object responsible for owning the current session can remain in
the Application layer.

Example:

```text
SessionDomain
     ↓
SessionController
     ↓
Application Navigation
```

This allows authentication, logout, or refresh-token failure to change the
root application state without coupling features together.

Session infrastructure is intentionally not included in the initial template
until an application actually requires it.

---

# Infrastructure

The template does not create an Infrastructure package by default.

Infrastructure should be introduced when real infrastructure responsibilities
exist.

Examples:

```text
Persistence
Keychain
Analytics
Push Notifications
Location
Database
```

Possible future structure:

```text
InfrastructurePackage
├── Persistence
├── SecurityKit
└── Analytics
```

Do not create modules simply because an architecture diagram suggests that
they might eventually be useful.

Create a module when there is a real responsibility to isolate.

---

# Dependency Injection

Initializer injection is the preferred dependency injection mechanism.

Preferred:

```swift
final class LoginViewModel {

    private let loginUseCase: any LoginUseCase

    init(
        loginUseCase: any LoginUseCase
    ) {
        self.loginUseCase = loginUseCase
    }
}
```

Avoid using global singleton access as the primary dependency mechanism.

Explicit dependencies make code easier to:

```text
Understand
Test
Replace
Compose
```

---

# Testing Strategy

Tests are organized around module boundaries.

Current examples:

```text
CoreUtilitiesTests
AuthenticationDomainTests
AuthenticationDataTests
```

Domain tests verify business behavior.

Data tests verify mapping, endpoint configuration, and repository integration
with abstractions such as `NetworkClient`.

Feature tests should not re-test behavior already owned by an external
package.

For example, `AuthenticationDataTests` should not test URLSession or HTTP
response validation because that behavior belongs to CoreNetworking.

The project's test targets are collected in:

```text
UnitTests.xctestplan
```

This allows the full unit test suite to be executed consistently from Xcode.

---

# Architectural Rules

The main dependency rules are:

```text
Domain
✓ Shared Domain modules when required
✗ Data
✗ Interface
✗ CoreNetworking
✗ SwiftUI

Data
✓ Domain
✓ Infrastructure required by the feature
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
✓ Application navigation
```

These rules are intentionally enforced through separate Swift Package
targets where practical.

---

# Scaling the Architecture

This template favors target-level modularization inside a small number of
Swift Packages.

For most applications:

```text
CorePackage
FeaturesPackage
Optional InfrastructurePackage
```

is sufficient.

A separate Swift Package per feature may become useful when:

```text
Different teams own independent features
Features have independent release lifecycles
Features are reused across multiple applications
Repository size or build isolation requires stronger boundaries
```

Until those requirements exist, target-per-layer provides strong modular
boundaries with significantly less package-management overhead.

---

# Guiding Principle

Architecture should make change easier, not simply increase the number of
layers.

Start with the modules provided by the template and introduce additional
abstractions only when the application has a concrete reason for them.

Prefer:

```text
Explicit dependencies
Clear ownership
Compiler-enforced boundaries
Small modules
Testable contracts
```

over architecture created only for theoretical completeness.
