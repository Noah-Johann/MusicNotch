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
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $coloredSpect) {
                Text("Colored spectogram")
            }
            
            LuminareToggle(isOn: $playerGlow) {
                Text ("Player glow")
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
