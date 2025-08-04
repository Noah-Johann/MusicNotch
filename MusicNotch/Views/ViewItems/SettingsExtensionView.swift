//
//  SettingsExtensionView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsExtensionView: View {
    @Default(.batteryExtension) private var batteryExtension
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $batteryExtension) {
                Text("Enable Battery Extension")
            }
            
        } header: {
            Text("Extensions (BETA)")
        }
        .padding(.bottom, 14)    }
}

#Preview {
    SettingsExtensionView()
}
