//
//  Untitled.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationDomain
import CoreNetworking

public final class DefaultAuthenticationRepository:
    AuthenticationRepository {

    private let networkClient: NetworkClient

    public init(
        networkClient: any NetworkClient
    ) {
        self.networkClient = networkClient
    }

    public func login(
        credentials: LoginCredentials
    ) async throws -> AuthenticationSession {

        let endpoint = try LoginEndpoint(
            credentials: credentials
        )

        let response = try await networkClient.request(endpoint)

        return response.toDomain()
    }
}
