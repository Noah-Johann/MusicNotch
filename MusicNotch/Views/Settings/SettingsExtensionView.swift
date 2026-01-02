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
            

            if !accessibilityManager.isReduceMotion && bluetoothRecognition {
                LuminarePicker(
                    elements: BluetoothSymbols.allCases,
                    selection: Binding(
                        get: { Defaults[.bluetoothSymbols] },
                        set: { Defaults[.bluetoothSymbols] = $0 }
                    ),
                    // .animation(LuminareConstants.animation),
                    columns: 2
                ) { option in
                    VStack(spacing: 6) {
                        if option == .videos {
                            if let path = Bundle.main.path(forResource: "AirPodsPro2", ofType: "mov") {
                                let url = URL(fileURLWithPath: path)
                                VideoView(url: url)
                                    .frame(width: 60, height: 60)
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Text("Video not found")
                            }
                        } else if option == .symbols {
                            Image(systemName: "airpods.pro")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 60)
                        }
                    }
                } .frame(height: 80)
                    .background(Color.black)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: bluetoothRecognition)
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsExtensionView()
}
