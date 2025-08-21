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
            let items: [(String, LocalizedStringResource, KeyboardShortcuts.Name)] = [
                ("chevron.up.chevron.down", "Toggle Notch", .toggleNotch),
                ("play", "Play/Pause", .playPause),
                ("forward", "Skip to Next Track", .nextTrack),
                ("backward", "Skip to Previous Track", .previousTrack),
                ("shuffle", "Toggle Shuffle", .toggleShuffle),
            ]
            ForEach(items, id: \.0) { image, label, name in
                KeyboardShortcuts.Recorder(
                    for: name
                ) {
                    HStack {
                        Image(systemName: "\(image)")
                            .imageScale(.large)
                            .bold()
                            .frame(width: 20)
                        
                        Text(label)
                            .padding(.horizontal, 9)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
            }
            
        } header: {
            Text("Keyboard shortcuts")
        }
        .padding(.bottom, 14)    }
}

#Preview {
    SettingsShortcutsView()
}
