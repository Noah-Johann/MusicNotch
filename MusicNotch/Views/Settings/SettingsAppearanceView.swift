//
//  SettingsAppearanceView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import JochexUI
import Defaults

struct SettingsAppearanceView: View {
    @Default(.coloredSpect) private var coloredSpect
    @Default(.coloredProgressBar) private var coloredProgressBar
    @Default(.musicPlayerVolume) private var musicPlayerVolume
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $coloredSpect) {
                Text("Colored spectogram")
            }
            
            LuminareToggle(isOn: $coloredProgressBar) {
                Text("Colored progress bar")
            }

            LuminareToggle(isOn: $musicPlayerVolume) {
                Text("Show music player volume slider")
            }
            
        } header: {
            Text("Appearance")
        }
    }
}

#Preview {
    SettingsAppearanceView()
}
