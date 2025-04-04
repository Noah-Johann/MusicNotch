//
//  aboutAppButton.swift
//  MusicNotch
//
//  Created by Noah Johann on 04.04.25.
//

import SwiftUI
import Luminare

@ViewBuilder
func aboutAppButton() -> some View {
    Button {
        copyInfo(text: "Version: \(Bundle.main.appVersion!) (\(Bundle.main.appBuild!))")
    } label: {
        HStack(spacing: 12) {
            Image("AboutIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)


            VStack(alignment: .leading) {
                Text(Bundle.main.appName)
                Text("Version: \(Bundle.main.appVersion!) (\(Bundle.main.appBuild!))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            }

            Spacer()
        }
        .padding(4)
    }
    .buttonStyle(LuminareCosmeticButtonStyle(Image(systemName: "clipboard")))
}
