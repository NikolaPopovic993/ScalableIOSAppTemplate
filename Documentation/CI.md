# Continuous Integration

The project includes a GitHub Actions workflow that validates pull requests
before they are merged into `main`.

The workflow is located at:

```text
.github/workflows/ci.yml
```

## Pull Request CI

The CI workflow runs automatically for pull requests targeting:

```text
main
```

The validation pipeline is intentionally small and focused on fast feedback.

```text
Pull Request
    ↓
Validate shell scripts
    ↓
Validate SharedPackage manifest
    ↓
Validate FeaturesPackage manifest
    ↓
Build iOS application
    ↓
Run tests
    ↓
Ready to merge
```

## Shell Script Validation

All shell scripts inside:

```text
Scripts/
```

are validated with:

```bash
bash -n
```

This catches shell syntax errors before a pull request is merged.

The CI does not execute setup, rename, bootstrap, or feature-generation scripts
as part of the standard pull request workflow.

Those scripts may modify the repository and are better suited for dedicated
integration testing when such testing becomes necessary.

## Swift Package Validation

The manifests for both local Swift packages are validated:

```text
Packages/SharedPackage
Packages/FeaturesPackage
```

using:

```bash
swift package dump-package
```

This ensures that changes to `Package.swift`, feature configuration, products,
targets, and dependencies still produce a valid Swift Package Manager
manifest.

## iOS Build

The application is built with `xcodebuild` using an iOS Simulator destination.

The CI build verifies that:

```text
Application
    ↓
Feature products
    ↓
Shared modules
    ↓
External packages
```

can be compiled together from a clean GitHub Actions environment.

Code signing is disabled because the pull request workflow only validates the
build and does not distribute the application.

## Tests

The configured Xcode Test Plan is executed on an iOS Simulator.

The workflow uses:

```text
ScalableIOSAppTemplate.xctestplan
```

so the CI test suite follows the same test configuration used by the project.

When adding a new test target that should participate in the standard
application test suite, also add it to the Test Plan.

## What CI Does Not Do

The standard pull request workflow intentionally does not perform:

```text
Application signing
App Store deployment
TestFlight deployment
Fastlane release automation
Bootstrap end-to-end testing
Project rename testing
Environment setup testing
Feature generator integration testing
```

These responsibilities are intentionally separate from the standard pull
request CI.

The goal of the default workflow is to answer one question:

> Is this pull request structurally valid, buildable, and passing the configured
> test suite?

## Continuous Delivery

Continuous delivery is intentionally not configured by the template.

Signing, certificates, provisioning profiles, App Store Connect credentials,
release environments, and deployment policies are application-specific.

A project created from this template may later introduce a delivery solution
such as:

```text
Xcode Cloud
GitHub Actions
Fastlane
Custom CI/CD infrastructure
```

without changing the architectural structure of the application.

## Extending CI

Additional checks should be introduced only when the project has a real need
for them.

Possible examples include:

```text
SwiftLint
Code coverage
Template integration tests
UI tests
Static analysis
Release validation
```

Avoid adding CI complexity only because a check may become useful in the
future.
