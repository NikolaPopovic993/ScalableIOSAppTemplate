//
//  RootView.swift
//  ScalableIOSAppTemplate
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import SwiftUI

struct RootView: View {

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 48))

                Text("Scalable iOS App Template")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Architecture foundation is ready.")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    RootView(
        container: AppContainer()
    )
}
