//
//  AppLoadingView.swift
//  SharedPackage
//
//  Created by Nikola Popovic on 7. 8. 2026..
//

import SwiftUI

public struct AppLoadingView: View {

    private let title: String?

    public init(
        title: String? = nil
    ) {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 12) {
            ProgressView()

            if let title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AppLoadingView(
        title: "Loading..."
    )
}
