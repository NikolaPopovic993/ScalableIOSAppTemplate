//
//  Untitled.swift
//  SharedPackage
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import Testing

@testable import CoreUtilities

struct StringTrimmedTests {

    @Test
    func trimmed_removesLeadingAndTrailingWhitespace() {
        let value = "  Nikola  "

        #expect(value.trimmed == "Nikola")
    }

    @Test
    func trimmed_removesNewlines() {
        let value = "\nHello\n"

        #expect(value.trimmed == "Hello")
    }
}
