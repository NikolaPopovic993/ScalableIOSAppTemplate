//
//  String+Trimmed.swift
//  SharedPackage
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import Foundation

public extension String {

    var trimmed: String {
        trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }
}
