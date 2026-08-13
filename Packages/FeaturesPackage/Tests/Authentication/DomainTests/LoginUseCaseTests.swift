//
//  LoginUseCaseTests.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import Testing

@testable import AuthenticationDomain

struct LoginUseCaseTests {
    
    

    @Test
    func execute_whenUsernameIsEmpty_throwsEmptyUsername() async {

        let repository = RepositoryStub()

        let sut = DefaultLoginUseCase(
            repository: repository
        )

        do {

            _ = try await sut.execute(
                credentials: LoginCredentials(
                    username: "",
                    password: "password"
                )
            )

            Issue.record(
                "Expected emptyUsername error."
            )

        } catch {

            #expect(
                error as? AuthenticationError ==
                .emptyUsername
            )
        }
    }
}

private struct RepositoryStub:
    AuthenticationRepository {

    func login(
        credentials: LoginCredentials
    ) async throws -> AuthenticationSession {

        throw StubError.notImplemented
    }
}

private enum StubError: Error {
    case notImplemented
}
