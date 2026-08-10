//
//  LoginViewState.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationDomain

public enum LoginViewState: Equatable {

    case idle

    case loading

    case success(
        AuthenticatedUser
    )

    case failure(
        String
    )
}
