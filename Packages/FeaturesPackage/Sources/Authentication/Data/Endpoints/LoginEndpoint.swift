//
//  LoginEndpoint.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import AuthenticationDomain
import CoreNetworking
import Foundation

struct LoginEndpoint: Endpoint {

    typealias Response = LoginResponseDTO

    let path = "auth/login"

    let method: HTTPMethod = .post

    let authenticationRequirement: AuthenticationRequirement = .none

    let body: Data?

    init(
        credentials: LoginCredentials
    ) throws {

        let requestDTO = LoginRequestDTO(
            username: credentials.username,
            password: credentials.password,
            expiresInMins: 30
        )

        body = try JSONEncoder().encode(
            requestDTO
        )
    }
}
