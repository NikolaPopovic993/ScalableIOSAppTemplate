//
//  AppContainer.swift
//  ScalableIOSAppTemplate
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import AuthenticationAssembly
import CoreNetworking
import CoreNetworkingDiagnostics
import SwiftUI

@MainActor
final class AppContainer {

    private let authenticationBuilder: AuthenticationFeatureBuilder

    init(
        configuration: AppConfiguration
    ) {

        let observers: [any NetworkEventObserver] =
            configuration.isLoggingEnabled
            ? [ConsoleNetworkObserver()]
            : []

        let networkClient = NetworkClientFactory.make(
            baseURL: configuration.apiBaseURL,
            defaultHeaders: NetworkHeaders.json,
            observers: observers
        )

        authenticationBuilder = AuthenticationFeatureBuilder(
            networkClient: networkClient
        )
    }

    func makeAuthenticationView() -> some View {
        authenticationBuilder.makeView()
    }
}
