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
    @Default(.lowPowerWarning) private var lowPowerWarning
    @Default(.bluetoothRecognition) private var bluetoothRecognition
    @Default(.enableGestures) private var enableGestures
    @Default(.hoverBehavior) private var hoverBehavior
    @Default(.autoMusicGlance) private var autoMusicGlance
    
    @ObservedObject private var updateManager = UpdateManager.shared
    
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
            .animation(.easeInOut(duration: 0.3), value: lowPowerWarning)
            .animation(.easeInOut(duration: 0.3), value: bluetoothRecognition)
            .animation(.easeInOut(duration: 0.3), value: enableGestures)
            .animation(.easeInOut(duration: 0.3), value: hoverBehavior)
            .animation(.easeInOut(duration: 0.3), value: autoMusicGlance)
            .animation(.easeInOut(duration: 0.3), value: updateManager.updateState)
            .animation(.bouncy(duration: 0.2), value: updateManager.updateProgress)

        }
    }
}
#Preview {
    SettingsView()
}
