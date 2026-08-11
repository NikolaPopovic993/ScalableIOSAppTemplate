//
//  LoginCredentials.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

public struct LoginCredentials: Sendable, Equatable {

    public let username: String
    public let password: String

    public init(
        username: String,
        password: String
    ) {
        self.username = username
        self.password = password
    }
}
