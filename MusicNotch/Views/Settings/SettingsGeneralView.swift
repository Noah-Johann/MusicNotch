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
    @Default(.silentLaunch) private var silentLaunch
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
                    .luminareToolTip(attachedTo: .topTrailing) {
                        Text("If hidden, settings can be accessed via right click on the player")
                            .padding()
                    }
                    .tint(.accentColor)
            }
            
            LuminareToggle(isOn: $silentLaunch) {
                Text("Enable silent launch")
            }

            
#if DEBUG
            LuminareToggle("Viewed Onboarding", isOn: $viewedOnboarding)
            
            Button {
                Task { @MainActor in
                    await NotchManager.shared.setNotchState(.compact, changeDisplay: true)
                }
            } label: {
                Text("Show notch")
            }
#endif
            
            
            Button {
                NSApp.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power")
                    Text("Quit")
                }
            }
            .luminareRoundingBehavior(bottom: true)
            .luminareBorderedStates(.none)
            .buttonStyle(.luminare)
            .frame(height: 37)
        } header: {
            Text("General")
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsGeneralView()
}
