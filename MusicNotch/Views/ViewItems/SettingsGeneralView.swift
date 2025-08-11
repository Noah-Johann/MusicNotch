//
//  SettingsGeneralView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import Defaults
import LaunchAtLogin

struct SettingsGeneralView: View {
    @Default(.showMenuBarItem) private var showMenuBarItem
    @Default(.showDockItem) private var showDockItem
    @Default(.viewedOnboarding) private var viewedOnboarding
    
    var body: some View {
        LuminareSection {
            LuminareToggle(
                isOn: Binding(
                    get: { LaunchAtLogin.isEnabled },
                    set: { value in LaunchAtLogin.isEnabled = value }
                )
            ) {
                Text("Launch at login")
            }
            LuminareToggle(isOn: $showMenuBarItem) {
                Text("Show menubar item")
                    .padding(.trailing, 5)
                    .luminarePopover(attachedTo: .topTrailing) {
                        Text("If hidden, settings can be accesed via right click on the player")
                            .padding()
                    }
                    .tint(.accentColor)
            }
            
            LuminareToggle(isOn: $showDockItem) {
                Text("Show dock icon")
            }
            
            #if DEBUG
            LuminareToggle("Viewed Onboarding", isOn: $viewedOnboarding)
            #endif
            
            
            Button {
                NSApp.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power")
                    Text("Quit")
                }
            } .buttonStyle(LuminareButtonStyle())
        } header: {
            Text("General")
        }
        .padding(.bottom, 14)    }
}

#Preview {
    SettingsGeneralView()
}
