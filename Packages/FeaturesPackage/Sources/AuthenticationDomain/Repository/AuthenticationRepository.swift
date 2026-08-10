//
//  AuthenticationRepository.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

public protocol AuthenticationRepository: Sendable {

    func login(
        credentials: LoginCredentials
    ) async throws -> AuthenticationSession
}
