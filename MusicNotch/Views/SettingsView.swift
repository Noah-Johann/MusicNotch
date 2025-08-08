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
    @Default(.mainDisplay) private var mainDisplay
    
    var body: some View {
        LuminarePane() {
            VStack {
                SettingsGeneralView()
                
                SettingsDisplayView()
                
                SettingsNotchView()
                
                SettingsAppearanceView()
                
                SettingsExtensionView()
                
                SettingsShortcutsView()

                SettingsAboutView()
                                
                SettingsAcknowledgementsView()
                
            } .padding(.horizontal, 5)
                .animation(.easeInOut(duration: 0.2), value: mainDisplay)
        }
    }
}
#Preview {
    SettingsView()
}
