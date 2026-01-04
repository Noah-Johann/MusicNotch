//
//  SettingsMusicView.swift
//  MusicNotch
//
//  Created by Noah Johann on 01.01.26.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsMusicView: View {
    @Default(.musicPlayer) private var musicPlayer
    
    var body: some View {
        LuminareSection {
            LuminarePicker(
                elements: MusicApp.allCases,
                selection: Binding(
                    get: { Defaults[.musicPlayer] },
                    set: { Defaults[.musicPlayer] = $0 }
                ),
                // .animation(LuminareConstants.animation),
                columns: 3
            ) { option in
                VStack(spacing: 12) {
                    option.image
                    Text(option.text)
                        .font(.title3)
                }
            }
            .buttonStyle(LuminareButtonStyle())
            .frame(height: 110)
            .padding(3)
        } header: {
            Text("Music")
        }
        .padding(.bottom, 14)
        .onChange(of: musicPlayer) {
            MusicManager.shared.updateMusic()
        }
    }
}

#Preview {
    SettingsMusicView()
}
