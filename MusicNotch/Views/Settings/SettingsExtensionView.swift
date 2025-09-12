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
    @Default(.hudExtension) private var hudExtension
    @Default(.accentColorHudSlider) private var accentColorHudSlider
    @Default(.gradientHudSlider) private var gradientHudSlider
    
    var body: some View {
        LuminareSection {
            LuminareSlider(
                value: $displayDuration,
                in: 1...10,
                step: 1,
                format: .number.precision(.fractionLength(0)),
                suffix: Text("s")
                
            ) {
                Text("Display duration")
            }
            .luminareSliderLayout(.regular)
            .padding(.bottom, 3)
            
        } header: {
            Text("Extensions (BETA)")
        }
        LuminareSection {
            LuminareToggle(isOn: $batteryExtension) {
                Text("Enable Battery Extension")
            }
        }
        
        LuminareSection {
            LuminareToggle(isOn: $hudExtension) {
                Text("HUD Extension")
            }
            
            LuminareToggle(isOn: $accentColorHudSlider) {
                Text("Accent color slider")
            }
            
            LuminareToggle(isOn: $gradientHudSlider) {
                Text("Gradient slider")
            }
        }
        
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsExtensionView()
}
