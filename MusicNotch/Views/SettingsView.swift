//
//  SettingsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 27.03.25.
//

import Foundation
import SwiftUI
import Luminare
import Defaults
import LaunchAtLogin
import KeyboardShortcuts


struct SettingsView: View {
    var body: some View {
        LuminarePane() {
            VStack {
                SettingsGeneralView()
                
                SettingsDisplayView()
                
                SettingsNotchView()
                
                SettingsGesturesView()
                
                SettingsMusicView()
                
                SettingsAppearanceView()
                
                SettingsMusicGlanceView()
                
                SettingsExtensionView()
                
                SettingsLockScreenView()
                                
                SettingsShortcutsView()
                
                SettingsPermissionView()

                SettingsAboutView()
            }
            .padding(.horizontal, 5)
        }
    }
}
#Preview {
    SettingsView()
}
