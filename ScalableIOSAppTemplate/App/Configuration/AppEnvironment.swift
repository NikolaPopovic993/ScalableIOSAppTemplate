//
//  AppEnvironment.swift
//  ScalableIOSAppTemplate
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

struct AppEnvironment: RawRepresentable, Hashable, Sendable {

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension AppEnvironment {

    static let development = AppEnvironment(
        rawValue: "development"
    )

    static let production = AppEnvironment(
        rawValue: "production"
    )
}
