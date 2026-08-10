//
//  AuthenticationError.swift
//  FeaturesPackage
//
//  Created by Nikola Popovic on 10. 8. 2026..
//

public enum AuthenticationError: Error, Sendable, Equatable {

    case emptyUsername
    case emptyPassword
}
