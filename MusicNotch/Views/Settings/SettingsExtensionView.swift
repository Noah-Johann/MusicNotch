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
    @Default(.lowPowerSound) private var lowPowerSound
    @Default(.pluggedInSound) private var pluggedInSound
    @Default(.lowPowerWarning) private var lowPowerWarning
    @Default(.lowBatteryThreshold) private var lowBatteryThreshold
    @Default(.displayDuration) private var displayDuration
    @Default(.hudExtension) private var hudExtension
    @Default(.hudDeviceIcons) private var hudDeviceIcons
    @Default(.accentColorHudSlider) private var accentColorHudSlider
    @Default(.gradientHudSlider) private var gradientHudSlider
    @Default(.bluetoothRecognition) private var bluetoothRecognition
    @Default(.bluetoothSymbols) private var bluetoothSymbols
    
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    
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
            
            LuminareToggle(isOn: $pluggedInSound) {
                HStack {
                    Text("Play charging sound")
                    
                    Button (action: {
                        playSound(sound: .pluggedIn)
                    }, label: {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .foregroundStyle(.secondary)
                            .imageScale(.large)
                    }) .buttonStyle(.plain)
                }
            }
            
            LuminareToggle(isOn: $lowPowerSound) {
                HStack {
                    Text("Play low power sound")
                    
                    Button (action: {
                        playSound(sound: .macLowBattery)
                    }, label: {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .foregroundStyle(.secondary)
                            .imageScale(.large)
                    }) .buttonStyle(.plain)
                }
            }
        }
        
        LuminareSection {
            LuminareToggle(isOn: $hudExtension) {
                Text("Enable HUD extension")
            }
            
            LuminareToggle(isOn: $hudDeviceIcons) {
                Text("Use device icons")
            }
            
            LuminareToggle(isOn: $accentColorHudSlider) {
                Text("Accent color slider")
            }
            
            LuminareToggle(isOn: $gradientHudSlider) {
                Text("Gradient slider")
            }
        }
            
        LuminareSection {
            LuminareToggle(isOn: $bluetoothRecognition) {
                Text("Enable Bluetooth extension")
            }
            
            LuminareToggle(isOn: $bluetoothSymbols) {
                Text("Use device icons")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: bluetoothRecognition)
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsExtensionView()
}
