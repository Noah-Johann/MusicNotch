//
//  aboutLicenseButton.swift
//  MusicNotch
//
//  Created by Noah Johann on 04.04.25.
//

import SwiftUI
import Luminare

@ViewBuilder
func aboutLicenseButton(name: String, license: String, link: URL, image: String) -> some View {
    @Environment(\.openURL) var openURL

    Button {
        openURL(link)
    } label: {
        HStack(spacing: 12) {
            Image(systemName: "\(image)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)


            VStack(alignment: .leading) {
                Text(name)

                Text(license)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            }

            Spacer()

        }
        .padding(12)
    }
    .buttonStyle(LuminareCosmeticButtonStyle(Image(systemName: "arrow.up.right")))
}
