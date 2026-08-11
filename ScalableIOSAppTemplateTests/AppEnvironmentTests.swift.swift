import Testing
@testable import ScalableIOSAppTemplate

struct AppEnvironmentTests {

    @Test
    func customEnvironment_preservesRawValue() {
        let environment = AppEnvironment(
            rawValue: "staging"
        )

        #expect(environment.rawValue == "staging")
    }

    @Test
    func arbitraryEnvironment_isSupported() {
        let environment = AppEnvironment(
            rawValue: "qa"
        )

        #expect(environment.rawValue == "qa")
    }

    @Test
    func development_hasExpectedRawValue() {
        #expect(
            AppEnvironment.development.rawValue == "development"
        )
    }

    @Test
    func production_hasExpectedRawValue() {
        #expect(
            AppEnvironment.production.rawValue == "production"
        )
    }

    @Test
    func environmentsWithSameRawValue_areEqual() {
        let first = AppEnvironment(
            rawValue: "staging"
        )

        let second = AppEnvironment(
            rawValue: "staging"
        )

        #expect(first == second)
    }

    @Test
    func environmentsWithDifferentRawValues_areNotEqual() {
        let first = AppEnvironment(
            rawValue: "staging"
        )

        let second = AppEnvironment(
            rawValue: "production"
        )

        #expect(first != second)
    }
}
