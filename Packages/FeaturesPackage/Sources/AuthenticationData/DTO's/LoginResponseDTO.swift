//
//  Untitled.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

struct LoginResponseDTO: Decodable, Sendable {

    let id: Int

    let username: String
    let email: String

    let firstName: String
    let lastName: String

    let image: String

    let accessToken: String
    let refreshToken: String
}
