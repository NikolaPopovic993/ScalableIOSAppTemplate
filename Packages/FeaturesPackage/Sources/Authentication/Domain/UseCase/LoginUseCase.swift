//
//  LoginUseCase.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import Foundation

public protocol LoginUseCase: Sendable {

    func execute(
        credentials: LoginCredentials
    ) async throws -> AuthenticationSession
}

public struct DefaultLoginUseCase: LoginUseCase {

    private let repository: any AuthenticationRepository

    public init(
        repository: any AuthenticationRepository
    ) {
        self.repository = repository
    }

    public func execute(
        credentials: LoginCredentials
    ) async throws -> AuthenticationSession {

        guard !credentials.username
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        else {
            throw AuthenticationError.emptyUsername
        }

        guard !credentials.password.isEmpty else {
            throw AuthenticationError.emptyPassword
        }

        return try await repository.login(
            credentials: credentials
        )
    }
}
