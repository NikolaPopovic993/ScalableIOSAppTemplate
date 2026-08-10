//
//  Untitled.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationDomain
import SharedUI
import SwiftUI

@MainActor
public struct LoginView: View {

    @State
    private var viewModel: LoginViewModel

    public init(
        viewModel: LoginViewModel
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
    }

    public var body: some View {

        NavigationStack {

            Form {

                credentialsSection

                statusSection

                loginSection
            }
            .navigationTitle(
                "Authentication"
            )
        }
    }
}

// MARK: - Content

private extension LoginView {

    var credentialsSection: some View {

        Section("Credentials") {

            TextField(
                "Username",
                text: $viewModel.username
            )
            .textInputAutocapitalization(
                .never
            )
            .autocorrectionDisabled()

            SecureField(
                "Password",
                text: $viewModel.password
            )

            Text(
                "Demo: emilys / emilyspass"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    var statusSection: some View {

        switch viewModel.state {

        case .idle:
            EmptyView()

        case .loading:

            Section {
                AppLoadingView(
                    title: "Signing in..."
                )
            }

        case .success(let user):

            Section("Authenticated User") {

                Text(user.fullName)

                Text(user.email)
                    .foregroundStyle(
                        .secondary
                    )
            }

        case .failure(let message):

            Section {

                Text(message)
                    .foregroundStyle(.red)
            }
        }
    }

    var loginSection: some View {

        Section {

            Button("Sign In") {

                Task {
                    await viewModel.login()
                }
            }
            .disabled(
                viewModel.state == .loading
            )
        }
    }
}
