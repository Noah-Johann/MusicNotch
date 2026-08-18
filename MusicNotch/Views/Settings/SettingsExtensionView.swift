//
//  SettingsExtensionView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import JochexUI
import Defaults

struct SettingsExtensionView: View {
    @Default(.batteryExtension) private var batteryExtension
    @Default(.lowPowerSound) private var lowPowerSound
    @Default(.pluggedInSound) private var pluggedInSound
    @Default(.lowPowerWarning) private var lowPowerWarning
    @Default(.lowBatteryThreshold) private var lowBatteryThreshold
    @Default(.displayDuration) private var displayDuration
    @Default(.hudExtension) private var hudExtension
    @Default(.hudDeviceIcons) private var hudDeviceIcons
    @Default(.hideHudLabel) private var hideHudLabel
    @Default(.accentColorHudSlider) private var accentColorHudSlider
    @Default(.gradientHudSlider) private var gradientHudSlider
    @Default(.bluetoothRecognition) private var bluetoothRecognition
    @Default(.bluetoothSymbols) private var bluetoothSymbols
        
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
            
        }
        
        LuminareSection {
            LuminareToggle(isOn: $batteryExtension) {
                Image(systemName: "bolt.fill")
                    .bold()
                    .foregroundStyle(batteryExtension ? Color.accentColor : .secondary)
                Text("Enable Battery extension")
            }
            
            LuminareToggle(isOn: $pluggedInSound) {
                Text("Play charging sound")
                Spacer()
                SettingsSoundItemView(sound: .pluggedIn)
            }
            
            LuminareToggle(isOn: $lowPowerWarning) {
                Text ("Warn on low battery")
            }
            if lowPowerWarning {
                LuminareSlider(
                    value: $lowBatteryThreshold,
                    in: 5...20,
                    step: 5,
                    format: .number.precision(.fractionLength(0...1)),
                    suffix: Text("%")
                    
                ) {
                    Text("Low battery threshold")
                }
                .luminareSliderLayout(.regular)
                .padding(.bottom, 3)
                
                LuminareToggle(isOn: $lowPowerSound) {
                    Text("Play low power sound")
                    Spacer()
                    SettingsSoundItemView(sound: .macLowBattery)
                }
            }
        } header: {
            Text("Battery")
        }

        LuminareSection {
            LuminareToggle(isOn: $hudExtension) {
                Image(systemName: "speaker.wave.2.fill")
                    .bold()
                    .foregroundStyle(hudExtension ? Color.accentColor : .secondary)
                Text("Enable HUD extension")
            }
            
            LuminareToggle(isOn: $hudDeviceIcons) {
                Text("Use device icons")
            }
            
            LuminareToggle(isOn: $hideHudLabel) {
                Text ("Hide labels")
            }
            
            LuminareToggle(isOn: $accentColorHudSlider) {
                Text("Accent color slider")
            }
            
            LuminareToggle(isOn: $gradientHudSlider) {
                Text("Gradient slider")
            }
        } header: {
            Text("HUD")
        }
            
        LuminareSection {
            LuminareToggle(isOn: $bluetoothRecognition) {
                Image(systemName: "headphones")
                    .bold()
                    .foregroundStyle(bluetoothRecognition ? Color.accentColor : .secondary)
                Text("Enable Bluetooth extension")
            }
            
            LuminareToggle(isOn: $bluetoothSymbols) {
                Text("Use device icons")
            }
        } header: {
            Text("Connectivity")
        }
    }
}

#Preview {
    SettingsExtensionView()
}
