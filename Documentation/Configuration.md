# Configuration

The template separates **Xcode build configurations** from **application environments**.

By default:

```text
Debug   → Development
Release → Production
```

These are only defaults. Projects can add environments such as:

```text
Staging
QA
Demo
Local
Preproduction
```

without changing the core configuration model.

---

## Structure

```text
Config/
├── Environments/
│   ├── Development.xcconfig
│   └── Production.xcconfig
├── Debug.xcconfig
├── Release.xcconfig
├── Shared.xcconfig
├── Secrets.example.xcconfig
└── Secrets.xcconfig
```

Runtime configuration is exposed through:

```text
App/
└── Configuration/
    ├── AppConfiguration.swift
    └── AppEnvironment.swift
```

Configuration flows through:

```text
.xcconfig
    ↓
Build Settings
    ↓
Info.plist
    ↓
AppConfiguration
```

Application code should use `AppConfiguration` instead of reading `Bundle` directly.

---

## Shared vs Environment Configuration

`Shared.xcconfig` contains values shared by the whole application:

```text
APP_DISPLAY_NAME
APP_BUNDLE_IDENTIFIER
MARKETING_VERSION
IPHONEOS_DEPLOYMENT_TARGET
```

Environment-specific values belong in:

```text
Config/Environments/
```

For example:

```text
APP_ENVIRONMENT = development
API_SCHEME = https
API_HOST = dev.api.example.com
```

A Production environment could use:

```text
APP_ENVIRONMENT = production
API_SCHEME = https
API_HOST = api.example.com
```

---

## Debug and Release

`Debug.xcconfig` composes the shared configuration with the default Development environment:

```text
#include "Shared.xcconfig"
#include "Environments/Development.xcconfig"

ENABLE_APP_LOGGING = YES
```

`Release.xcconfig` uses Production:

```text
#include "Shared.xcconfig"
#include "Environments/Production.xcconfig"

ENABLE_APP_LOGGING = NO
```

Build configuration and application environment are separate concepts.

A project can later introduce combinations such as:

```text
Debug → Staging
Release → Staging
Release → Production
```

if needed.

---

## Custom Environments

`AppEnvironment` is intentionally open-ended:

```swift
struct AppEnvironment: RawRepresentable, Hashable, Sendable {

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
```

The template provides convenient defaults:

```swift
.development
.production
```

but custom values work without changing the type:

```swift
AppEnvironment(
    rawValue: "staging"
)
```

To add Staging, create:

```text
Config/Environments/Staging.xcconfig
```

with:

```text
APP_ENVIRONMENT = staging

API_SCHEME = https
API_HOST = staging.api.example.com
```

Then include that environment from the desired build configuration.

---

## Environment vs Application Behavior

Use the environment to identify **where the application is running**.

Use explicit configuration values to control **how the application behaves**.

Prefer:

```swift
if configuration.isLoggingEnabled {
    logger.enable()
}
```

instead of:

```swift
if configuration.environment.rawValue == "development" {
    logger.enable()
}
```

Likewise, use:

```swift
configuration.apiBaseURL
```

instead of choosing an API URL with environment-specific `if` or `switch` statements.

Environment checks are most useful for diagnostics, logging metadata, analytics metadata, and developer tooling.

Business logic should not normally depend on environment names.

---

## Adding Configuration Values

To add a new value:

1. Add it to the appropriate `.xcconfig`.
2. Expose it through `Info.plist`.
3. Add a typed property to `AppConfiguration`.
4. Consume that property from application code.

For example:

```text
ENABLE_ANALYTICS = YES
```

can become:

```swift
let isAnalyticsEnabled: Bool
```

in `AppConfiguration`.

---

## Secrets

`Secrets.example.xcconfig` is committed to Git.

`Secrets.xcconfig` is local and should remain ignored.

Do not commit real API keys, tokens, or other secrets.

---

## Setup

The setup script configures the application identity and initial API values:

```bash
./Scripts/setup.sh \
    --display-name "My App" \
    --bundle-id "com.example.myapp" \
    --api-scheme "https" \
    --api-host "api.example.com" \
    --yes
```

The initial API configuration is written to both default environments.

After setup, Development and Production can be configured independently.

---

## Guiding Principle

> Use the environment to identify where the application is running. Use explicit configuration values to control application behavior.

The template provides Development and Production as useful defaults, but does not restrict the application to those environments.
