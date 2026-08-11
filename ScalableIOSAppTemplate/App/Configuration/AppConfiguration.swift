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
        let environment = readEnvironment(from: bundle)
        let isLoggingEnabled = readLoggingEnabled(from: bundle)

        return AppConfiguration(
            environment: environment,
            isLoggingEnabled: isLoggingEnabled,
            apiBaseURL: readAPIBaseURL(
                 from: bundle
             )
        )
    }
}

private extension AppConfiguration {

    static func readAPIBaseURL(
        from bundle: Bundle
    ) -> URL {

        guard
            let scheme = bundle.object(
                forInfoDictionaryKey: "API_SCHEME"
            ) as? String,
            let host = bundle.object(
                forInfoDictionaryKey: "API_HOST"
            ) as? String
        else {
            preconditionFailure(
                "Missing API configuration."
            )
        }

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
}

// MARK: - Private

private extension AppConfiguration {

    enum Key {
        static let environment = "APP_ENVIRONMENT"
        static let loggingEnabled = "ENABLE_APP_LOGGING"
    }

    static func readEnvironment(
        from bundle: Bundle
    ) -> AppEnvironment {
        guard
            let value = bundle.object(
                forInfoDictionaryKey: Key.environment
            ) as? String,
            !value.isEmpty
        else {
            preconditionFailure(
                "Missing \(Key.environment) configuration."
            )
        }

        return AppEnvironment(
            rawValue: value
        )
    }

    static func readLoggingEnabled(
        from bundle: Bundle
    ) -> Bool {
        guard
            let value = bundle.object(
                forInfoDictionaryKey: Key.loggingEnabled
            ) as? String
        else {
            preconditionFailure(
                "Missing \(Key.loggingEnabled) configuration."
            )
        }

        return value == "YES"
    }
}
