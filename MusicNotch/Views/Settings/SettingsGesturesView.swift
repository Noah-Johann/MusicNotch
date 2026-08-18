//
//  SettingsGesturesView.swift
//  MusicNotch
//
//  Created by Noah Johann on 13.11.25.
//

import SwiftUI
import Luminare
import JochexUI
import Defaults

struct SettingsGesturesView: View {
    @Default(.enableGestures) private var enableGestures
    @Default(.mediaGestures) private var mediaGestures
 
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $enableGestures) {
                Text("Enable Gesture control")
                Spacer()
                SettingsInfoItemView { Text("Swipe vertical to open and close the notch.") }
            }
            
            if enableGestures {
                LuminareToggle(isOn: $mediaGestures) {
                    Text("Enable Media Gestures")
                    Spacer()
                    SettingsInfoItemView { Text("Swipe horizontal to change the current track.") }
                }
            }
        } header: {
            Text("Gestures")
        }
    }
}

#Preview {
    SettingsGesturesView()
}
