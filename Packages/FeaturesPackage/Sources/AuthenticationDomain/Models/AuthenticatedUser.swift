//
//  AuthenticatedUser.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

import Foundation

public struct AuthenticatedUser: Sendable, Equatable {

    public let id: Int
    public let username: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let imageURL: URL?

    public init(
        id: Int,
        username: String,
        email: String,
        firstName: String,
        lastName: String,
        imageURL: URL?
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
    }

    public var fullName: String {
        "\(firstName) \(lastName)"
    }
}
