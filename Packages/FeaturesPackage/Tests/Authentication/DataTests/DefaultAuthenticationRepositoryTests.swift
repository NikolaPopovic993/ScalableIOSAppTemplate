//
//  DefaultAuthenticationRepositoryTests.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationDomain
import CoreNetworking
import Testing

@testable import AuthenticationData

struct DefaultAuthenticationRepositoryTests {

    @Test
    func login_whenNetworkRequestSucceeds_mapsResponseToDomain() async throws {

        let response = LoginResponseDTO(
            id: 1,
            username: "emilys",
            email: "emily@example.com",
            firstName: "Emily",
            lastName: "Johnson",
            image: "https://example.com/emily.png",
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        let networkClient = NetworkClientStub(
            response: response
        )

        let sut = DefaultAuthenticationRepository(
            networkClient: networkClient
        )

        let result = try await sut.login(
            credentials: LoginCredentials(
                username: "emilys",
                password: "emilyspass"
            )
        )

        #expect(result.user.id == 1)
        #expect(result.user.username == "emilys")
        #expect(result.user.email == "emily@example.com")
        #expect(result.user.firstName == "Emily")
        #expect(result.user.lastName == "Johnson")

        #expect(
            result.user.imageURL?.absoluteString ==
            "https://example.com/emily.png"
        )

        #expect(result.accessToken == "access-token")
        #expect(result.refreshToken == "refresh-token")
    }
}

private struct NetworkClientStub: NetworkClient {

    let response: LoginResponseDTO

    func request<E: Endpoint>(
        _ endpoint: E
    ) async throws -> E.Response {

        guard let response = response as? E.Response else {
            throw NetworkClientStubError.unexpectedResponseType
        }

        return response
    }
}

private enum NetworkClientStubError: Error {
    case unexpectedResponseType
}
