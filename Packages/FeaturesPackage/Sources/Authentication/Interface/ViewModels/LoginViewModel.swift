//
//  LoginViewModel.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationDomain
import Observation

@MainActor
@Observable
public final class LoginViewModel {

    public var username = ""

    public var password = ""

    public private(set) var state:
        LoginViewState = .idle

    private let loginUseCase: any LoginUseCase

    public init(
        loginUseCase: any LoginUseCase
    ) {
        self.loginUseCase = loginUseCase
    }

    public func login() async {

        guard state != .loading else {
            return
        }

        state = .loading

        do {
            let session = try await loginUseCase.execute(
                credentials: LoginCredentials(
                    username: username,
                    password: password
                )
            )

            state = .success(
                session.user
            )
        } catch AuthenticationError.emptyUsername {
            state = .failure(
                "Username is required."
            )
        } catch AuthenticationError.emptyPassword {
            state = .failure(
                "Password is required."
            )
        } catch {
            state = .failure(
                "Login failed. Please try again."
            )
        }
    }
}
