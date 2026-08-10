//
//  AuthenticationSession.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

public struct AuthenticationSession: Sendable, Equatable {

    public let user: AuthenticatedUser

    public let accessToken: String
    public let refreshToken: String

    public init(
        user: AuthenticatedUser,
        accessToken: String,
        refreshToken: String
    ) {
        self.user = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
