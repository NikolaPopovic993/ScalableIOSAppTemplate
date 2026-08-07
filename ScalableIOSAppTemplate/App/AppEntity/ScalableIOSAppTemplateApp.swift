//
//  ScalableIOSAppTemplateApp.swift
//  ScalableIOSAppTemplate
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import SwiftUI

@main
struct ScalableIOSAppTemplateApp: App {

    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView(
                container: container
            )
        }
    }
}
