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

    static func load(
        from bundle: Bundle = .main
    ) -> AppConfiguration {
        let environment = readEnvironment(from: bundle)
        let isLoggingEnabled = readLoggingEnabled(from: bundle)

        return AppConfiguration(
            environment: environment,
            isLoggingEnabled: isLoggingEnabled
        )
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
            let environment = AppEnvironment(rawValue: value)
        else {
            preconditionFailure(
                "Missing or invalid \(Key.environment) configuration."
            )
        }

        return environment
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
