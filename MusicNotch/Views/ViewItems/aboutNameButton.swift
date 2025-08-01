//
//  aboutNameButton.swift
//  MusicNotch
//
//  Created by Noah Johann on 04.04.25.
//

import SwiftUI
import Luminare


@MainActor @ViewBuilder
func aboutButton(name: LocalizedStringKey, role: LocalizedStringKey, link: URL, image: Image) -> some View {
    @Environment(\.openURL) var openURL

    Button {
        openURL(link)
    } label: {
        HStack(spacing: 12) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                }
                .clipShape(.circle)

            VStack(alignment: .leading) {
                Text(name)

                Text(role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
    }
    .buttonStyle(LuminareCosmeticButtonStyle(icon: Image(systemName: "arrow.up.right")))
}
