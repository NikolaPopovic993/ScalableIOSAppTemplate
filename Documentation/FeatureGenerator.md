# Feature Generator

The template includes a feature generator that creates the initial structure
for a new feature inside `FeaturesPackage`.

The generator is intentionally focused on scaffolding.

It does not attempt to generate business logic, repositories, use cases,
endpoints, view models, navigation, or application-specific dependencies.

The script is located at:

```text
Scripts/generate_feature.sh
```

## Basic Usage

Run the generator interactively:

```bash
./Scripts/generate_feature.sh
```

The generator asks which modules the feature requires.

Example:

```text
Feature name: Profile

Include Domain? [Y/n]: y
Include Data? [Y/n]: y
Include Interface? [Y/n]: y
Include Assembly? [Y/n]: y

Use CoreNetworking? [y/N]: y
Generate Domain/Data tests? [Y/n]: y

Generate feature? [Y/n]: y
```

## Flexible Feature Modules

A feature does not need to contain every architectural module.

Available modules are:

```text
Domain
Data
Interface
Assembly
```

The feature should contain only the modules that provide useful architectural
boundaries for that feature.

For example, a full feature may contain:

```text
Profile
├── Domain
├── Data
├── Interface
└── Assembly
```

A simple UI-only feature may contain:

```text
About
└── Interface
```

A feature with business logic and UI may contain:

```text
Calculator
├── Domain
└── Interface
```

A background feature may contain:

```text
BackgroundSync
├── Domain
├── Data
└── Assembly
```

A data capability may contain only:

```text
ImageCache
└── Data
```

The template does not require all features to follow the same structure.

## CLI Usage

The generator can also run non-interactively.

### Full Feature

```bash
./Scripts/generate_feature.sh \
    --name Profile \
    --modules all \
    --networking \
    --tests \
    --yes
```

### Interface-only Feature

```bash
./Scripts/generate_feature.sh \
    --name About \
    --modules interface \
    --no-networking \
    --no-tests \
    --yes
```

### Domain + Interface

```bash
./Scripts/generate_feature.sh \
    --name Calculator \
    --modules domain,interface \
    --no-networking \
    --tests \
    --yes
```

### Background Feature

```bash
./Scripts/generate_feature.sh \
    --name BackgroundSync \
    --modules domain,data,assembly \
    --networking \
    --tests \
    --yes
```

### Data-only Feature

```bash
./Scripts/generate_feature.sh \
    --name ImageCache \
    --modules data \
    --no-networking \
    --tests \
    --yes
```

## Available Arguments

### `--name`

Sets the feature name.

The name must use PascalCase.

Examples:

```text
Profile
Authentication
BackgroundSync
```

Example usage:

```bash
--name Profile
```

### `--modules`

Selects the modules that should be created.

Supported values:

```text
domain
data
interface
assembly
all
```

Multiple modules are separated with commas:

```bash
--modules domain,data,interface
```

Using:

```bash
--modules all
```

creates:

```text
Domain
Data
Interface
Assembly
```

### `--networking`

Enables `CoreNetworking`.

Networking is supported when the feature contains:

```text
Data
Assembly
```

or both.

Example:

```bash
--networking
```

### `--no-networking`

Creates the feature without `CoreNetworking`.

### `--tests`

Creates supported test targets.

Automatic test generation currently supports:

```text
DomainTests
DataTests
```

Test targets are created only when their corresponding modules exist.

For example:

```text
Domain + Interface
```

with tests enabled creates:

```text
DomainTests
```

but not:

```text
DataTests
```

because the Data module does not exist.

### `--no-tests`

Creates the feature without test targets.

### `--yes`

Skips the final interactive confirmation.

This is useful for scripts and automated workflows.

## Generated Feature Configuration

The generator registers the feature inside:

```text
Packages/FeaturesPackage/Package.swift
```

For example:

```swift
FeatureConfiguration(
    name: "Calculator",
    modules: [
        .domain,
        .interface
    ],
    usesNetworking: false,
    hasTests: true
),
```

This configuration produces:

```text
CalculatorDomain
CalculatorInterface
CalculatorDomainTests
```

It does not produce:

```text
CalculatorData
CalculatorAssembly
CalculatorDataTests
```

because those modules were not requested.

## Generated Source Structure

A full feature may look like:

```text
Packages/FeaturesPackage/
├── Sources/
│   └── Profile/
│       ├── Domain/
│       ├── Data/
│       ├── Interface/
│       └── Assembly/
└── Tests/
    └── Profile/
        ├── DomainTests/
        └── DataTests/
```

A smaller feature may contain only:

```text
Packages/FeaturesPackage/
└── Sources/
    └── About/
        └── Interface/
```

The physical directory structure follows the modules selected for the feature.

## Module Dependencies

`FeatureConfiguration` automatically creates dependencies between modules that
exist.

For a full feature:

```text
Domain
Data
Interface
Assembly
```

the dependency graph is approximately:

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

If a module does not exist, no dependency to that module is created.

For example:

```text
Domain
Interface
```

creates:

```text
Interface
└── Domain
```

without creating Data or Assembly.

This allows small features to remain small without introducing unnecessary
architectural layers.

## CoreNetworking

`CoreNetworking` is treated as standard infrastructure by
`FeatureConfiguration`.

For example:

```swift
FeatureConfiguration(
    name: "BackgroundSync",
    modules: [
        .domain,
        .data,
        .assembly
    ],
    usesNetworking: true,
    hasTests: true
)
```

produces a dependency graph approximately like:

```text
BackgroundSyncDomain

BackgroundSyncData
├── BackgroundSyncDomain
└── CoreNetworking

BackgroundSyncAssembly
├── BackgroundSyncDomain
├── BackgroundSyncData
└── CoreNetworking
```

`CoreNetworking` is not automatically added to Domain or Interface.

Domain should remain independent from networking infrastructure.

## Custom Dependencies

Dependencies that are not part of the standard feature configuration should be
declared explicitly.

`FeatureConfiguration` provides:

```swift
domainDependencies
dataDependencies
interfaceDependencies
assemblyDependencies
```

For example, if the Interface module uses `SharedUI`:

```swift
FeatureConfiguration(
    name: "Profile",
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

This means:

```text
ProfileInterface
├── ProfileDomain
└── SharedUI
```

If Data uses `SharedUtilities`:

```swift
FeatureConfiguration(
    name: "Settings",
    modules: [
        .domain,
        .data,
        .interface
    ],
    usesNetworking: true,
    hasTests: true,
    dataDependencies: [
        .product(
            name: "SharedUtilities",
            package: "SharedPackage"
        )
    ]
)
```

This produces approximately:

```text
SettingsData
├── SettingsDomain
├── CoreNetworking
└── SharedUtilities
```

Dependencies remain explicit instead of introducing configuration flags for
every possible library.

## Adding a Module to an Existing Feature

The structure selected when a feature is generated is not permanent.

A feature can start small and gain additional modules as it grows.

For example, a feature may initially contain:

```swift
FeatureConfiguration(
    name: "Profile",
    modules: [
        .domain,
        .data
    ],
    usesNetworking: true,
    hasTests: true
)
```

Its source structure may be:

```text
Profile
├── Domain
└── Data
```

Later the feature may require UI.

Create:

```text
Packages/FeaturesPackage/Sources/Profile/Interface/
```

Then update the configuration:

```swift
FeatureConfiguration(
    name: "Profile",
    modules: [
        .domain,
        .data,
        .interface
    ],
    usesNetworking: true,
    hasTests: true
)
```

`FeatureConfiguration` automatically connects:

```text
ProfileInterface
        ↓
ProfileDomain
```

because the Domain module already exists.

The same approach can be used to add:

```text
Domain
Data
Interface
Assembly
```

later when a feature grows.

The generator therefore creates the initial feature structure but does not lock
the feature into that structure permanently.

## Using SharedUI

`SharedUI` is not automatically added by the generator.

If a feature needs reusable application UI components, add the dependency
explicitly:

```swift
interfaceDependencies: [
    .product(
        name: "SharedUI",
        package: "SharedPackage"
    )
]
```

Then the Interface module can:

```swift
import SharedUI
```

This keeps the dependency graph explicit.

The generator does not provide a dedicated `usesSharedUI` option.

## Using SharedUtilities

The same principle applies to `SharedUtilities`.

For example:

```swift
dataDependencies: [
    .product(
        name: "SharedUtilities",
        package: "SharedPackage"
    )
]
```

A dependency should be added only to the module that actually needs it.

For example:

```text
Domain needs dependency
→ domainDependencies

Data needs dependency
→ dataDependencies

Interface needs dependency
→ interfaceDependencies

Assembly needs dependency
→ assemblyDependencies
```

## Using a Feature from the Host Application

Generating a feature makes its Swift Package products available, but the host
application target should explicitly depend on the product it uses.

For example, an Interface-only feature may expose:

```text
AboutInterface
```

Add `AboutInterface` to the application target.

The application can then use:

```swift
import AboutInterface
```

A more complex feature may expose its application entry point through:

```text
AuthenticationAssembly
```

The application target can depend on:

```text
AuthenticationAssembly
```

instead.

The host application should depend only on feature products that it actually
uses.

The feature generator intentionally does not modify the Xcode application
target automatically.

## Tests

When test generation is enabled:

```text
Domain exists
→ DomainTests generated

Data exists
→ DataTests generated
```

For example:

```swift
modules: [
    .domain,
    .interface
],
hasTests: true
```

generates:

```text
FeatureDomainTests
```

but does not generate:

```text
FeatureDataTests
```

because Data does not exist.

Automatic generation currently does not create:

```text
InterfaceTests
AssemblyTests
```

Those test targets can be introduced manually if a feature requires them.

## Git Safety

The generator requires a clean Git working tree before modifying the
repository.

Before generating a feature:

```bash
git status
```

should report:

```text
nothing to commit, working tree clean
```

This makes generated changes easy to inspect and revert.

If a generated feature was created only for testing, the uncommitted changes
can be removed with:

```bash
git reset --hard HEAD
git clean -fd
```

These commands should only be used when all uncommitted changes can safely be
discarded.

## Manifest Validation

After generating a feature, the script validates:

```text
Packages/FeaturesPackage/Package.swift
```

using:

```bash
swift package \
    --package-path Packages/FeaturesPackage \
    dump-package
```

If validation fails, the generator restores the previous `Package.swift` and
removes the generated feature directories.

This prevents an invalid feature configuration from being left in the
repository.

## Invalid Configurations

The generator validates some invalid combinations before creating files.

For example:

```bash
./Scripts/generate_feature.sh \
    --name About \
    --modules interface \
    --networking \
    --yes
```

is rejected because automatic `CoreNetworking` integration requires Data or
Assembly.

A feature must also contain at least one module.

For example, a feature cannot be generated with all modules disabled.

## What the Generator Does Not Do

The generator intentionally does not modify:

```text
AppContainer
RootView
Application navigation
Xcode application target dependencies
Test Plan configuration
Feature-specific dependencies
```

It also does not generate application-specific implementation such as:

```text
Business models
Repositories
Use cases
Endpoints
View models
Navigation flows
```

Those decisions depend on the feature and should remain explicit.

## Why the Generator Is Intentionally Small

The generator should remove repetitive setup work without making architectural
decisions for the developer.

Its responsibility is:

```text
Feature name
    ↓
Selected modules
    ↓
Directories
    ↓
SwiftPM products and targets
    ↓
Optional networking
    ↓
Optional tests
```

After that, implementation belongs to the application.

This avoids generating large amounts of boilerplate that may never be needed.

## Design Principle

Start with the smallest feature structure that makes sense.

```text
Simple feature
    ↓
small module set

Feature grows
    ↓
add required modules

Dependencies grow
    ↓
add explicit dependencies
```

A feature should not have Domain, Data, Interface, or Assembly only because the
template provides those modules.

Each module should exist because it provides a useful architectural boundary.
