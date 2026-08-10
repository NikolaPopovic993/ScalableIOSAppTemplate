//
//  LoginRequestDTO.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

struct LoginRequestDTO: Encodable, Sendable {

    let username: String
    let password: String
    let expiresInMins: Int
}
