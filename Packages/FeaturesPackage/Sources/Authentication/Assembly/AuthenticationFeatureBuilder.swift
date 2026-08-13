//
//  AuthenticationFeatureBuilder.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationData
import AuthenticationDomain
import AuthenticationInterface
import CoreNetworking
import SwiftUI

@MainActor
public struct AuthenticationFeatureBuilder {

    private let networkClient: any NetworkClient

    public init(
        networkClient: any NetworkClient
    ) {
        self.networkClient = networkClient
    }

    public func makeView() -> some View {

        let repository = DefaultAuthenticationRepository(
            networkClient: networkClient
        )

        let loginUseCase = DefaultLoginUseCase(
            repository: repository
        )

        let viewModel = LoginViewModel(
            loginUseCase: loginUseCase
        )

        return LoginView(
            viewModel: viewModel
        )
    }
}
