import Foundation
import Testing
@testable import ScalableIOSAppTemplate

struct AppConfigurationTests {

    @Test
    func configuration_supportsCustomEnvironment() throws {
        let apiBaseURL = try #require(
            URL(string: "https://staging.example.com")
        )

        let configuration = AppConfiguration(
            environment: AppEnvironment(
                rawValue: "staging"
            ),
            isLoggingEnabled: true,
            apiBaseURL: apiBaseURL
        )

        #expect(
            configuration.environment.rawValue == "staging"
        )

        #expect(
            configuration.isLoggingEnabled
        )

        #expect(
            configuration.apiBaseURL == apiBaseURL
        )
    }

    @Test
    func configuration_supportsProductionEnvironment() throws {
        let apiBaseURL = try #require(
            URL(string: "https://api.example.com")
        )

        let configuration = AppConfiguration(
            environment: .production,
            isLoggingEnabled: false,
            apiBaseURL: apiBaseURL
        )

        #expect(
            configuration.environment == .production
        )

        #expect(
            !configuration.isLoggingEnabled
        )

        #expect(
            configuration.apiBaseURL == apiBaseURL
        )
    }
}
