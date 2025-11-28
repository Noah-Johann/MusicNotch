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
    @Default(.lockSound) private var lockSound
    @Default(.unlockSound) private var unlockSound
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
            
            LuminareToggle(isOn: $lockSound) {
                HStack {
                    Text("Play lock sound")
                    
                    Button(action: {
                        playSound(sound: .lock)
                    }, label: {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .foregroundStyle(.secondary)
                            .imageScale(.large)
                    }) .buttonStyle(.plain)
                }
            }
            
            LuminareToggle(isOn: $unlockSound) {
                HStack {
                    Text("Play unlock sound")
                    
                    Button (action: {
                        playSound(sound: .unlock)
                    }, label: {
                        Image(systemName: "speaker.wave.2.circle.fill")
                            .foregroundStyle(.secondary)
                            .imageScale(.large)
                    }) .buttonStyle(.plain)
                }
            }
        }
            
        LuminareSection {
            LuminareToggle(isOn: $bluetoothRecognition) {
                Text("Enable Bluetooth extension")
            }
            
            LuminareToggle(isOn: $bluetoothSymbols) {
                Text("Use device symbols")
            }
        }
        
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsExtensionView()
}
