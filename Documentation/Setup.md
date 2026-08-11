# Setup

This document describes how to create a new application from the template and
configure the repository for development.

The recommended workflow is to start from a fresh copy of the repository and
use the provided bootstrap script.

## Before You Start

The setup and rename scripts modify repository files.

Run them from a clean Git working tree.

Check:

```bash
git status
```

before starting.

The expected result is:

```text
nothing to commit, working tree clean
```

Keeping the repository clean makes setup changes easy to inspect and recover
from if necessary.

---

# Recommended Setup

The recommended setup command is:

```bash
./Scripts/bootstrap.sh
```

The bootstrap script combines the project rename and application configuration
steps into a single workflow.

It is intended to be used when creating a new application from the template.

Conceptually:

```text
Fresh template
    ↓
bootstrap.sh
    ↓
Project rename
    ↓
Application configuration
    ↓
Configured project
```

The script presents the resolved configuration before applying changes.

Review the values carefully before confirming.

---

# What Bootstrap Configures

The bootstrap workflow may configure application-specific values such as:

```text
Project name
Application display name
Bundle identifier
API scheme
API host
```

The exact generated values should be reviewed after setup.

Application-specific configuration is stored through the project's
configuration files rather than being scattered throughout Swift source code.

---

# Manual Setup

The bootstrap command is the preferred workflow, but rename and configuration
can also be run independently.

## Rename the Project

Run:

```bash
./Scripts/rename_project.sh
```

The rename script updates the template project name and the related project
references.

It also supports non-interactive usage.

For example:

```bash
./Scripts/rename_project.sh \
    --name MyApplication \
    --yes
```

Use PascalCase for the application/project name.

Examples:

```text
MyApplication
WeatherApp
GitHubClient
```

After the rename completes, inspect:

```bash
git status
```

before continuing.

---

## Configure the Application

Application configuration can be updated with:

```bash
./Scripts/setup.sh
```

The setup script is responsible for application-specific configuration values.

These values are reflected through the `.xcconfig` based configuration system.

The setup workflow should preserve existing local secret configuration rather
than replacing it unnecessarily.

---

# Configuration Files

Configuration files live inside:

```text
Config/
├── Shared.xcconfig
├── Debug.xcconfig
├── Release.xcconfig
└── Secrets.example.xcconfig
```

These files separate build configuration from Swift implementation code.

---

## Shared.xcconfig

`Shared.xcconfig` contains values shared between build configurations.

Typical examples include:

```text
APP_DISPLAY_NAME
APP_BUNDLE_IDENTIFIER
API_SCHEME
API_HOST
MARKETING_VERSION
CURRENT_PROJECT_VERSION
IPHONEOS_DEPLOYMENT_TARGET
```

Values that are identical between Debug and Release should generally live here.

---

## Debug.xcconfig

`Debug.xcconfig` contains development-oriented configuration.

For example, Debug may configure:

```text
Development environment
Development API configuration
Additional logging
Debug-specific behavior
```

The exact values remain application-specific.

---

## Release.xcconfig

`Release.xcconfig` contains production-oriented configuration.

For example:

```text
Production environment
Production API configuration
Reduced debug logging
Release-specific behavior
```

Build configuration and backend environment are related concepts but are not
the same thing.

The template currently provides Debug and Release as the default build
configurations.

Projects may later introduce additional environments such as:

```text
Development
Staging
QA
Production
```

when required.

---

# API Configuration

API configuration is split into components such as:

```text
API_SCHEME
API_HOST
```

instead of storing a complete URL in `.xcconfig`.

For example:

```text
API_SCHEME = https
API_HOST = api.example.com
```

This avoids issues caused by `//` being interpreted as comment syntax inside
`.xcconfig` files.

Swift application configuration can combine those values when constructing the
base URL.

---

# Application Configuration

Swift code should read configuration through the application's configuration
abstraction rather than accessing configuration values throughout the codebase.

Application configuration belongs under:

```text
App/Configuration/
```

Typical files include:

```text
AppConfiguration.swift
AppEnvironment.swift
```

Conceptually:

```text
.xcconfig
    ↓
Build settings / Info configuration
    ↓
AppConfiguration
    ↓
Application dependencies
```

This keeps environment knowledge centralized.

---

# Secrets

Real secrets should not be committed to the repository.

The repository provides:

```text
Secrets.example.xcconfig
```

as an example of the expected structure.

If a project requires local secret configuration, create the corresponding
local file according to the project's setup and keep it ignored by Git.

Never commit values such as:

```text
Private API keys
Signing credentials
Access tokens
Passwords
Private service credentials
```

to the public repository.

Before committing configuration changes, verify:

```bash
git status
```

and inspect any new configuration files carefully.

---

# Git Ignore

Local SwiftPM and build artifacts should remain untracked.

Examples include:

```text
.swiftpm/
.build/
```

Local secret configuration should also remain ignored.

`Package.resolved`, when intentionally tracked by the application project,
should remain committed so dependency resolution is reproducible.

---

# Swift Packages

The repository contains local application packages:

```text
Packages/
├── FeaturesPackage/
└── SharedPackage/
```

`FeaturesPackage` contains application feature modules.

`SharedPackage` contains reusable application-specific modules.

Generic dependencies that are reusable across applications may be remote Swift
packages.

For example:

```text
CoreNetworking
```

is consumed as a reusable remote dependency.

---

# Opening the Project

After setup, open:

```text
ScalableIOSAppTemplate.xcodeproj
```

or the renamed project if `rename_project.sh` has already been executed.

Allow Xcode to resolve Swift Package Manager dependencies.

Then perform an initial build:

```text
⌘B
```

and run tests:

```text
⌘U
```

Both should succeed before feature development begins.

---

# Package Manifest Validation

The local package manifests can also be validated from Terminal.

For `SharedPackage`:

```bash
swift package \
    --package-path Packages/SharedPackage \
    dump-package >/dev/null \
    && echo "SharedPackage ✅"
```

For `FeaturesPackage`:

```bash
swift package \
    --package-path Packages/FeaturesPackage \
    dump-package >/dev/null \
    && echo "FeaturesPackage ✅"
```

`dump-package` is useful for validating the package manifests without trying to
build the package for the macOS host platform.

---

# Why Plain `swift build` Is Not the Default Package Check

The application packages target iOS.

Running:

```bash
swift build \
    --package-path Packages/FeaturesPackage
```

from macOS may attempt to evaluate/build dependencies for the host platform.

A dependency may support a different minimum macOS version even though the
actual application is intended for iOS.

For this template:

```text
swift package dump-package
```

is used for lightweight manifest validation.

The actual compilation check is performed through the Xcode iOS build.

---

# Feature Generation

After initial setup, new features can be created with:

```bash
./Scripts/generate_feature.sh
```

The generator supports flexible module selection.

For example:

```bash
./Scripts/generate_feature.sh \
    --name Profile \
    --modules domain,data,interface \
    --networking \
    --tests \
    --yes
```

A feature does not need to contain all available architectural modules.

See:

[Feature Generator](FeatureGenerator.md)

for complete usage instructions.

---

# Adding Feature Products to the Application

Creating a feature inside `FeaturesPackage` does not automatically add every
feature product to the host application target.

The application should explicitly depend on the feature product it needs.

For example, an Interface-only feature may create:

```text
AboutInterface
```

Add `AboutInterface` to the application target before using:

```swift
import AboutInterface
```

A full feature may instead expose its entry point through:

```text
AuthenticationAssembly
```

This explicit dependency keeps the application target aware only of the
features it actually uses.

---

# Continuous Integration

Pull requests targeting:

```text
main
```

are validated by GitHub Actions.

The standard workflow checks:

```text
Shell syntax
SharedPackage manifest
FeaturesPackage manifest
iOS application build
Configured tests
```

See:

[Continuous Integration](CI.md)

for details.

---

# After Setup

A successful initial setup should leave the project in a state where:

```text
Project name is correct
Bundle identifier is correct
Application display name is correct
API configuration is correct
Swift packages resolve
Application builds
Tests pass
Git working tree contains only expected setup changes
```

Review:

```bash
git status
```

and:

```bash
git diff
```

before creating the initial application-specific commit.

---

# Recovery

Because setup scripts modify files, Git is the primary recovery mechanism.

If a setup experiment was performed on a clean working tree and all
uncommitted changes can safely be discarded:

```bash
git reset --hard HEAD
git clean -fd
```

will restore the repository to the last commit.

These commands permanently remove uncommitted changes and untracked files.

Use them only when that is intentional.

For important work, prefer creating a commit or separate branch before
experimenting.

---

# Recommended Workflow

A typical project creation flow is:

```text
Create fresh repository from template
        ↓
Verify clean Git state
        ↓
Run bootstrap
        ↓
Review configuration
        ↓
Open Xcode
        ↓
Resolve packages
        ↓
Build
        ↓
Run tests
        ↓
Commit initial project configuration
        ↓
Start feature development
```

The setup tooling should reduce repetitive project configuration while keeping
the resulting project understandable and editable without the scripts.
