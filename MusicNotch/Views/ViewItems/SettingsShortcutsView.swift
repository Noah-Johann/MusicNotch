//
//  SettingsShortcutsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import KeyboardShortcuts
import Defaults

struct SettingsShortcutsView: View {
    var body: some View {
        LuminareSection {
            KeyboardShortcuts.Recorder("Toggle Notch",
                                       name: .toggleNotch)
            .padding(7)
            
            KeyboardShortcuts.Recorder("Play/Pause",
                                       name: .playPause)
            .padding(7)
            
            KeyboardShortcuts.Recorder("Skip to Next Track",
                                       name: .nextTrack)
            .padding(7)
            
            KeyboardShortcuts.Recorder("Skip to Previous Track",
                                       name: .previousTrack)
            .padding(7)
            
            KeyboardShortcuts.Recorder("Toggle Shuffle",
                                       name: .toggleShuffle)
            .padding(7)
            
        } header: {
            Text("Keyboard shortcuts")
        }
        .padding(.bottom, 14)    }
}

#Preview {
    SettingsShortcutsView()
}
