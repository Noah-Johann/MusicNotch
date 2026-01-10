//
//  SettingsAppearanceView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsAppearanceView: View {
    @Default(.coloredSpect) private var coloredSpect
    @Default(.playerGlow) private var playerGlow
    @Default(.musicPlayerVolume) private var musicPlayerVolume
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $coloredSpect) {
                Text("Colored spectogram")
            }
            
            LuminareToggle(isOn: $playerGlow) {
                Text ("Player glow")
            }
            
            LuminareToggle(isOn: $musicPlayerVolume) {
                Text("Show music player volume slider")
            }
            
        } header: {
            Text("Appearance")
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsAppearanceView()
}
