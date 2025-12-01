//
//  SettingsLockScreenView.swift
//  MusicNotch
//
//  Created by Noah Johann on 01.12.25.
//

import SwiftUI
import Defaults
import Luminare

struct SettingsLockScreenView: View {
    @Default(.lockExtension) private var lockExtension
    @Default(.lockSound) private var lockSound
    @Default(.unlockSound) private var unlockSound
    @Default(.lockPlayer) private var lockPlayer
    @Default(.lockPosition) private var lockPosition
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $lockExtension) {
                Text("Enable LockScreen icon")
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
            
            LuminareToggle(isOn: $lockPlayer) {
                Text("Enable LockScreen player")
            }
            
            LuminareSlider(
                value: $lockPosition,
                in: -20...20,
                step: 5,
                format: .number.precision(.fractionLength(0...1)),
                suffix: Text("px")
                
            ) {
                Text("Position adjustment")
            }
            .luminareSliderLayout(.regular)
            .padding(.bottom, 3)
            
        } header: {
            Text("LockScreen")
        }
    
    }
}

#Preview {
    SettingsLockScreenView()
}
