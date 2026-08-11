# Feature Generator

The template includes a feature generator for creating new modular application
features.

Run:

```bash
./Scripts/generate_feature.sh
```

The generator creates the feature structure, registers its Swift targets, and
configures common optional dependencies.

---

## Interactive Usage

Example:

```text
Feature name: Profile

Use CoreNetworking? [Y/n]:
Y

Use SharedUI? [Y/n]:
Y

Create Domain and Data tests? [Y/n]:
Y

Create this feature? [Y/n]:
Y
```

The generator creates:

```text
Packages/FeaturesPackage/
├── Sources/
│   └── Profile/
│       ├── Domain/
│       ├── Data/
│       ├── Interface/
│       └── Assembly/
│
└── Tests/
    └── Profile/
        ├── DomainTests/
        └── DataTests/
```

---

## Generated Swift Targets

For a feature named:

```text
Profile
```

the package creates:

```text
ProfileDomain
ProfileData
ProfileInterface
ProfileAssembly
```

When tests are enabled:

```text
ProfileDomainTests
ProfileDataTests
```

The physical directory structure and Swift module names are intentionally
different.

For example:

```text
Swift target:
ProfileDomain

Physical location:
Sources/Profile/Domain
```

This keeps the filesystem feature-first while preserving compiler-enforced
module boundaries.

---

## Feature Manifest

The generator automatically registers the feature in:

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

The manifest helper converts this configuration into:

```text
Products
Targets
Dependencies
Source paths
Optional test targets
```

This avoids repeating large Swift Package target declarations for every
feature.

---

# Generator Options

## Networking

Enable networking interactively:

```text
Use CoreNetworking? Y
```

or through CLI:

```bash
--networking
```

Result:

```swift
usesNetworking: true
```

CoreNetworking is automatically added to the feature targets that require
networking infrastructure.

Disable with:

```bash
--no-networking
```

Result:

```swift
usesNetworking: false
```

---

## SharedUI

Enable SharedUI interactively:

```text
Use SharedUI? Y
```

or:

```bash
--shared-ui
```

Result:

```swift
usesSharedUI: true
```

The manifest adds:

```swift
.product(
    name: "SharedUI",
    package: "SharedPackage"
)
```

to the feature Interface target.

Disable with:

```bash
--no-shared-ui
```

Result:

```swift
usesSharedUI: false
```

---

## Tests

Enable:

```bash
--tests
```

This creates:

```text
<Feature>DomainTests
<Feature>DataTests
```

Disable with:

```bash
--no-tests
```

Result:

```swift
hasTests: false
```

---

# Non-Interactive Usage

A fully configured feature:

```bash
./Scripts/generate_feature.sh \
    --name Profile \
    --networking \
    --shared-ui \
    --tests \
    --yes
```

A minimal feature:

```bash
./Scripts/generate_feature.sh \
    --name Onboarding \
    --no-networking \
    --no-shared-ui \
    --no-tests \
    --yes
```

Available options:

```text
--name <name>
--networking
--no-networking
--shared-ui
--no-shared-ui
--tests
--no-tests
--yes
--help
```

---

# Generated Code

The generator intentionally creates only minimal compilation-ready
placeholders.

It does not automatically create:

```text
Repositories
Use cases
ViewModels
DTOs
Endpoints
Mappers
Services
```

These types should be introduced when actual feature requirements justify
them.

The generator is responsible for architectural scaffolding, not business
implementation.

---

# Adding SharedUI Later

A feature may initially be created without SharedUI:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: false,
    hasTests: true
)
```

If SharedUI is required later, change:

```swift
usesSharedUI: false
```

to:

```swift
usesSharedUI: true
```

The manifest automatically adds SharedUI to the feature Interface target.

The Interface module may then use:

```swift
import SharedUI
```

Example:

```swift
import SharedUI
import SwiftUI

public struct ProfileView: View {

    public init() {}

    public var body: some View {
        AppLoadingView()
    }
}
```

No manual target declaration is required.

---

# Adding Networking Later

Networking works in the same way.

Change:

```swift
usesNetworking: false
```

to:

```swift
usesNetworking: true
```

CoreNetworking is then added to the feature modules configured by the
manifest.

---

# Adding Additional Dependencies

The generator intentionally exposes only common feature options:

```text
CoreNetworking
SharedUI
Tests
```

Other dependencies should be added explicitly to the layer that actually
requires them.

`FeatureConfiguration` supports:

```swift
domainDependencies
dataDependencies
interfaceDependencies
assemblyDependencies
```

All of these dependencies are optional and default to empty arrays.

A normal feature therefore remains simple:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true
)
```

---

## Adding SharedUtilities to Data

Suppose `ProfileData` requires functionality from:

```text
SharedUtilities
```

Configure:

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

`ProfileData` can then use:

```swift
import SharedUtilities
```

The resulting dependency graph is:

```text
ProfileData
├── ProfileDomain
├── CoreNetworking
└── SharedUtilities
```

Other Profile modules do not automatically receive access to
`SharedUtilities`.

---

## Adding SharedUtilities to Interface

If only the Interface layer requires it:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true,
    interfaceDependencies: [
        .product(
            name: "SharedUtilities",
            package: "SharedPackage"
        )
    ]
)
```

Then:

```swift
import SharedUtilities
```

is available inside:

```text
ProfileInterface
```

but not automatically in Domain, Data, or Assembly.

---

## Adding a Domain Dependency

Domain dependencies should be used carefully because Domain should remain
independent from UI and infrastructure.

A pure shared business module may be appropriate.

For example:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true,
    domainDependencies: [
        .product(
            name: "UserDomain",
            package: "SharedPackage"
        )
    ]
)
```

This could represent:

```text
ProfileDomain
    ↓
UserDomain
```

Avoid adding infrastructure such as:

```text
Networking
UI
Persistence implementations
```

to Domain.

---

## Adding an Assembly Dependency

Assembly may require additional concrete infrastructure during feature
composition.

Example:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true,
    assemblyDependencies: [
        .product(
            name: "Analytics",
            package: "SharedPackage"
        )
    ]
)
```

The dependency becomes available only to:

```text
ProfileAssembly
```

---

# Multiple Custom Dependencies

More than one dependency can be declared.

Example:

```swift
FeatureConfiguration(
    name: "Profile",
    usesNetworking: true,
    usesSharedUI: true,
    hasTests: true,
    domainDependencies: [
        .product(
            name: "UserDomain",
            package: "SharedPackage"
        )
    ],
    dataDependencies: [
        .product(
            name: "SharedUtilities",
            package: "SharedPackage"
        )
    ],
    interfaceDependencies: [
        .product(
            name: "DesignTokens",
            package: "SharedPackage"
        )
    ]
)
```

Each dependency remains scoped to the module that consumes it.

---

# Why Custom Dependencies Are Not Generator Questions

The generator does not ask:

```text
Use SharedUtilities?
Use Analytics?
Use UserDomain?
Use Session?
Use Validation?
```

because this would make the generator increasingly coupled to the
application's evolving architecture.

Instead:

```text
Common dependency
        ↓
Generator option

Feature-specific dependency
        ↓
Explicit layer dependency
```

This keeps the generator small while still allowing features to scale.

---

# Dependency Guidelines

Prefer the narrowest possible dependency scope.

If only `ProfileData` requires SharedUtilities:

```text
Correct:
ProfileData → SharedUtilities
```

Avoid:

```text
ProfileDomain → SharedUtilities
ProfileData → SharedUtilities
ProfileInterface → SharedUtilities
ProfileAssembly → SharedUtilities
```

unless all four modules genuinely consume it.

Explicit dependency ownership improves:

```text
Architecture clarity
Compile-time boundaries
Testability
Future refactoring
Module reuse
```

---

# Local vs Remote Dependencies

Use this general rule:

```text
Feature-specific implementation
        ↓
Feature module

Application-specific shared capability
        ↓
SharedPackage

Reusable across multiple applications
        ↓
Separate remote Swift Package
```

Examples:

```text
ProfileMapper
→ ProfileData

AppLoadingView
→ SharedUI

Application-specific String utility
→ SharedUtilities

Current user business abstraction
→ UserDomain when genuinely shared

Generic networking
→ CoreNetworking remote package
```

---

# Adding Tests Later

A feature may initially have:

```swift
hasTests: false
```

Changing it to:

```swift
hasTests: true
```

causes the manifest to expect:

```text
Tests/<Feature>/DomainTests
Tests/<Feature>/DataTests
```

Those directories and source files must also exist.

For this reason, enabling tests through the generator when creating a feature
is usually recommended.

---

# What the Generator Does Not Modify

The generator intentionally does not modify:

```text
AppContainer
RootView
Application navigation
project.pbxproj
Xcode Test Plan
Business-specific integration
Custom feature dependencies
```

A generator cannot determine whether a feature belongs in:

```text
Root flow
Navigation destination
Tab
Sheet
Full-screen cover
Child flow
```

Those decisions remain explicit.

---

# After Generating a Feature

Typical next steps:

```text
1. Open Xcode
2. Resolve package changes if required
3. Add the feature Assembly product to the host application if needed
4. Wire the FeatureBuilder through AppContainer
5. Add generated tests to the Xcode Test Plan if required
6. Add feature-specific dependencies when needed
7. Implement business requirements
```

---

# Git Safety

The generator requires a clean Git working tree.

Before generation:

```bash
git status
```

should show:

```text
nothing to commit, working tree clean
```

Generated changes can then be reviewed with:

```bash
git status
git diff
```

For disposable generator testing, changes can be removed with:

```bash
git reset --hard HEAD
git clean -fd
```

> `git clean -fd` removes untracked files and directories. Review its effect
> before using it in a working repository.
