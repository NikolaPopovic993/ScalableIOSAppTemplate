//
//  LoginResponseDTO+Mapping.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationDomain
import Foundation

extension LoginResponseDTO {

    func toDomain() -> AuthenticationSession {

        let user = AuthenticatedUser(
            id: id,
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName,
            imageURL: URL(
                string: image
            )
        )

        return AuthenticationSession(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}
