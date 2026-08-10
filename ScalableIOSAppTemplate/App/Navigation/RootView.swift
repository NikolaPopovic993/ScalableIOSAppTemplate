//
//  RootView.swift
//  ScalableIOSAppTemplate
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import SwiftUI
import CoreUI

import SwiftUI

@MainActor
struct RootView: View {

    private let container: AppContainer

    init(
        container: AppContainer
    ) {
        self.container = container
    }

    var body: some View {

        container.makeAuthenticationView()
    }
}

#Preview {
    RootView(
        container: AppContainer(
            configuration: AppConfiguration(
                environment: .development,
                isLoggingEnabled: true,
                apiBaseURL: URL(string: "https://test.com")!
            )
        )
    )
}
