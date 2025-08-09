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
    @Default(.displayDuration) private var displayDuration
    
    var body: some View {
        LuminareSection {
            LuminareSlider(
                value: $displayDuration,
                in: 1...10,
                format: .number.precision(.fractionLength(0...1)),
                suffix: Text("s")
                
            ) {
                Text("Display duration")
            }
            .luminareSliderLayout(.regular)
            
            LuminareToggle(isOn: $batteryExtension) {
                Text("Enable Battery Extension")
            }
            
        } header: {
            Text("Extensions (BETA)")
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsExtensionView()
}
