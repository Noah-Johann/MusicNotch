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
    @Default(.lockExtension) private var lockExtension
    
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
            Text("Extensions")
        }
        LuminareSection {
            LuminareToggle(isOn: $batteryExtension) {
                Text("Enable Battery extension")
            }
        }
        
        LuminareSection {
            LuminareToggle(isOn: $hudExtension) {
                Text("Enable HUD extension")
            }
            
            LuminareToggle(isOn: $accentColorHudSlider) {
                Text("Accent color slider")
            }
            
            LuminareToggle(isOn: $gradientHudSlider) {
                Text("Gradient slider")
            }
        }
        
        LuminareSection {
            LuminareToggle(isOn: $lockExtension) {
                Text("Enable LockScreen extension")
            }
        }
        
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsExtensionView()
}
