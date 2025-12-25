//
//  CosmeticTwoLineButton.swift
//  MusicNotch
//
//  Created by Noah Johann on 25.12.25.
//

import SwiftUI
import Luminare

@ViewBuilder
func CosmeticTwoLineButton(heading: LocalizedStringKey, description: LocalizedStringKey, image: Image, hoverIcon: String, circleOverlay: Bool = false, height: CGFloat = 40, action: @escaping () -> Void) -> some View {
    Button {
        action()
    } label: {
        HStack(spacing: 12) {
            if circleOverlay {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                }
                .clipShape(.circle)
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: height)
            }

            VStack(alignment: .leading) {
                Text(heading)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
    }
    .buttonStyle(LuminareCosmeticButtonStyle(icon: Image(systemName: hoverIcon)))
}

