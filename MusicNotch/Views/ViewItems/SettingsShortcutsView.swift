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
            .frame(height: 40)
        } header: {
            Text("Keyboard shortcuts")
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsShortcutsView()
}
