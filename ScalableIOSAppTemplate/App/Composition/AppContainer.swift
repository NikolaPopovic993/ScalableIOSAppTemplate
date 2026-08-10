//
//  AppContainer.swift
//  ScalableIOSAppTemplate
//
//  Created by Nikola Popovic on 7. 8. 2026..
//


import CoreNetworking
import AuthenticationAssembly
import SwiftUI

@MainActor
final class AppContainer {

    let configuration: AppConfiguration

    private let networkClient: NetworkClient
    private let authenticationBuilder: AuthenticationFeatureBuilder

    init(
        configuration: AppConfiguration
    ) {

        self.configuration = configuration

        networkClient =
            NetworkClientFactory.make(
                baseURL:
                    configuration.apiBaseURL,

                defaultHeaders:
                    NetworkHeaders.json
            )
        
        authenticationBuilder = AuthenticationFeatureBuilder(networkClient: networkClient)
    }

    func makeAuthenticationView() -> some View {
        authenticationBuilder.makeView()
    }
}
