//
//  AppConfiguration.swift
//  ScalableIOSAppTemplate
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import Foundation

struct AppConfiguration: Sendable {

    let environment: AppEnvironment
    let isLoggingEnabled: Bool
    let apiBaseURL: URL

    static func load(
        from bundle: Bundle = .main
    ) -> AppConfiguration {
        AppConfiguration(
            environment: readEnvironment(
                from: bundle
            ),
            isLoggingEnabled: readLoggingEnabled(
                from: bundle
            ),
            apiBaseURL: readAPIBaseURL(
                from: bundle
            )
        )
    }
}

// MARK: - Private

private extension AppConfiguration {

    enum Key {
        static let environment = "APP_ENVIRONMENT"
        static let loggingEnabled = "ENABLE_APP_LOGGING"
        static let apiScheme = "API_SCHEME"
        static let apiHost = "API_HOST"
    }

    static func readEnvironment(
        from bundle: Bundle
    ) -> AppEnvironment {
        let value = readRequiredString(
            forKey: Key.environment,
            from: bundle
        )

        return AppEnvironment(
            rawValue: value
        )
    }

    static func readLoggingEnabled(
        from bundle: Bundle
    ) -> Bool {
        guard let value = bundle.object(
            forInfoDictionaryKey: Key.loggingEnabled
        ) else {
            preconditionFailure(
                "Missing \(Key.loggingEnabled) configuration."
            )
        }

        if let boolValue = value as? Bool {
            return boolValue
        }

        if let stringValue = value as? String {
            switch stringValue
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased() {

            case "yes", "true", "1":
                return true

            case "no", "false", "0":
                return false

            default:
                break
            }
        }

        preconditionFailure(
            "Invalid \(Key.loggingEnabled) configuration."
        )
    }

    static func readAPIBaseURL(
        from bundle: Bundle
    ) -> URL {
        let scheme = readRequiredString(
            forKey: Key.apiScheme,
            from: bundle
        )

        let host = readRequiredString(
            forKey: Key.apiHost,
            from: bundle
        )

        var components = URLComponents()
        components.scheme = scheme
        components.host = host

        guard let url = components.url else {
            preconditionFailure(
                "Invalid API configuration."
            )
        }

        return url
    }

    static func readRequiredString(
        forKey key: String,
        from bundle: Bundle
    ) -> String {
        guard
            let value = bundle.object(
                forInfoDictionaryKey: key
            ) as? String
        else {
            preconditionFailure(
                "Missing \(key) configuration."
            )
        }

        let trimmedValue = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedValue.isEmpty else {
            preconditionFailure(
                "Empty \(key) configuration."
            )
        }

        return trimmedValue
    }
}
