# Feature Generator

The template includes a feature generator for creating new modular application
features.

Run:

```bash
./Scripts/generate_feature.sh
```

The generator creates the feature structure, registers its Swift targets, and
configures optional dependencies.

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

The manifest helper converts this configuration into products, targets,
dependencies, and physical paths.

---

# Generator Options

## Networking

Enable:

```text
Use CoreNetworking? Y
```

or:

```bash
--networking
```

This adds CoreNetworking to feature modules that require networking
infrastructure.

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

Enable:

```text
Use SharedUI? Y
```

or:

```bash
--shared-ui
```

This adds:

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

These types should be introduced when feature requirements require them.

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

If SharedUI is required later, simply change:

```swift
usesSharedUI: false
```

to:

```swift
usesSharedUI: true
```

The manifest automatically adds the required package dependency.

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

No manual target dependency declaration is required.

---

# Adding Networking Later

The same approach applies to networking.

Change:

```swift
usesNetworking: false
```

to:

```swift
usesNetworking: true
```

The manifest adds CoreNetworking to the relevant feature targets.

Feature code may then import the networking abstraction where required.

---

# Adding Tests Later

Change:

```swift
hasTests: false
```

to:

```swift
hasTests: true
```

Then create the expected directories:

```text
Tests/<Feature>/DomainTests
Tests/<Feature>/DataTests
```

The manifest expects those paths when test targets are enabled.

For that reason, using the generator when initially creating the feature is
recommended.

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
```

A generator cannot know whether a feature should be presented as:

```text
Root flow
Navigation destination
Tab
Sheet
Full-screen cover
Child flow
```

That integration remains explicit.

---

# After Generating a Feature

Typical next steps are:

```text
1. Open Xcode
2. Resolve package changes if required
3. Add the feature Assembly product to the host application when needed
4. Wire the FeatureBuilder through AppContainer
5. Add generated test targets to the Xcode Test Plan if needed
6. Implement actual business requirements
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

To discard a test generation:

```bash
git reset --hard HEAD
git clean -fd
```

> `git clean -fd` removes untracked files and directories. Use it carefully.
