//
//  ScalableIOSAppTemplateUITests.swift
//  ScalableIOSAppTemplateUITests
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import XCTest

final class ScalableIOSAppTemplateUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchesAuthenticationScreen() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.navigationBars["Authentication"]
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(app.textFields["Username"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
    }
}
