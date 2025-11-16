//
//  SettingsMusicGlanceView.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.11.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsMusicGlanceView: View {
    @Default(.autoMusicGlance) private var autoMusicGlance
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $autoMusicGlance) {
                Text("Automatic MusicGlance")
            }
        } header: {
            Text("MusicGlance")
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsMusicGlanceView()
}
