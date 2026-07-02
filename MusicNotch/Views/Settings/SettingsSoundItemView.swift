//
//  SettingsSoundItemView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.06.26.
//

import SwiftUI

struct SettingsSoundItemView: View {
    var sound: Sound
    
    var body: some View {
        Image(systemName: "speaker.wave.2.circle")
            .foregroundStyle(.secondary)
            .imageScale(.large)
            .onTapGesture { SoundHelper.shared.playSound(sound: sound)}
    }
}

#Preview {
    SettingsSoundItemView(sound: .macLowBattery)
}
