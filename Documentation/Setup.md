# Project Setup

The template provides scripts for preparing a new application from the GitHub
template.

The recommended entry point is:

```bash
./Scripts/bootstrap.sh
```

---

# Bootstrap

Bootstrap combines:

```text
Technical Xcode project rename
+
Application configuration
```

into one interactive workflow.

Run:

```bash
./Scripts/bootstrap.sh
```

---

## Bootstrap Input

The script asks for:

```text
Technical project name
Application display name
Bundle identifier
API scheme
API host
```

Example:

```text
Technical project name:
Biologer

Application display name:
Biologer

Bundle identifier:
rs.biologer.app

API scheme:
https

API host:
dummyjson.com
```

The script displays a summary before modifying any files.

---

# What Bootstrap Renames

Bootstrap performs the technical project rename through
`rename_project.sh`.

For example:

```text
ScalableIOSAppTemplate.xcodeproj
        ↓
Biologer.xcodeproj
```

It also updates:

```text
Application target references
Shared scheme
Application source directory
App entry file
Unit test directory
UI test directory
Xcode Test Plan
Project name references
```

---

# What Bootstrap Configures

Application-facing configuration is handled by:

```text
setup.sh
```

Values include:

```text
APP_DISPLAY_NAME
APP_BUNDLE_IDENTIFIER
API_SCHEME
API_HOST
```

These values are stored through `.xcconfig` files.

---

# Build Configuration

Configuration files:

```text
Config/
├── Shared.xcconfig
├── Debug.xcconfig
├── Release.xcconfig
└── Secrets.example.xcconfig
```

Shared application configuration may include:

```text
APP_DISPLAY_NAME
APP_BUNDLE_IDENTIFIER
API_SCHEME
API_HOST
MARKETING_VERSION
CURRENT_PROJECT_VERSION
IPHONEOS_DEPLOYMENT_TARGET
```

---

## Debug

Example:

```text
APP_ENVIRONMENT = development
ENABLE_APP_LOGGING = YES
```

---

## Release

Example:

```text
APP_ENVIRONMENT = production
ENABLE_APP_LOGGING = NO
```

---

# Secrets

The repository contains:

```text
Config/Secrets.example.xcconfig
```

The setup workflow creates:

```text
Config/Secrets.xcconfig
```

when necessary.

`Secrets.xcconfig` is intentionally ignored by Git.

Do not commit:

```text
API keys
Private tokens
Signing credentials
Private certificates
Service credentials
Production secrets
```

Existing local secret values are preserved when setup runs again.

---

# Manual Scripts

Bootstrap is recommended, but the lower-level scripts can be used
independently.

---

## Rename Only

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

This changes the technical project identity.

It does not change:

```text
Application display name
Bundle identifier
API configuration
Secrets
```

---

## Configure Only

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

---

# Recommended Workflow

For a new repository:

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
Select Development Team if required
        ↓
Review Secrets.xcconfig
        ↓
Build
        ↓
Run
        ↓
Tests
```

---

# Clean Git Requirement

Bootstrap and rename operations require a clean Git working tree.

Check with:

```bash
git status
```

This protects existing work and provides a predictable rollback point.

---

# Recovery

Inspect generated changes:

```bash
git status
git diff
```

For a fresh repository created from the template, generated changes may be
discarded with:

```bash
git reset --hard HEAD
git clean -fd
```

> `git clean -fd` deletes untracked files and directories. Review what will be
> removed before using it.

---

# After Bootstrap

After the process completes:

```text
1. Open the renamed Xcode project
2. Check Development Team
3. Review local secrets
4. Resolve Swift Packages if required
5. Build the application
6. Run the application
7. Run tests with ⌘ + U
```

New application features can then be created with:

```bash
./Scripts/generate_feature.sh
```

See:

[Feature Generator](FeatureGenerator.md)
