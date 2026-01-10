//
//  CosmeticOneLineButton.swift
//  MusicNotch
//
//  Created by Noah Johann on 25.12.25.
//

import SwiftUI
import Luminare

@ViewBuilder
func CosmeticOneLineButton(title: LocalizedStringKey, image: Image, hoverIcon: String, action: @escaping () -> Void) -> some View {
    Button {
        action()
    } label: {
        HStack (spacing: 12) {
            image
                .imageScale(.large)
            Text(title)
            Spacer()
        }
        .padding(.horizontal, 8)
        .frame(height: 36)
    } .buttonStyle(LuminareCosmeticButtonStyle(icon: Image(systemName: hoverIcon)))
}


