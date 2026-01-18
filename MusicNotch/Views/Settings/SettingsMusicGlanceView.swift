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
    @Default(.musicGlanceDuration) private var musicGlanceDuration
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $autoMusicGlance) {
                Text("Automatic MusicGlance")
            }
            
            if Defaults[.autoMusicGlance] {
                LuminareSlider(
                    value: $musicGlanceDuration,
                    in: 1...10,
                    step: 1,
                    format: .number.precision(.fractionLength(0)),
                    suffix: Text("s")
                    
                ) {
                    Text("Display duration")
                }
                .luminareSliderLayout(.compact)
                .padding(.vertical, 3)
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
