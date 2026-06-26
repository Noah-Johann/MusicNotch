//
//  SettingsLockScreenView.swift
//  MusicNotch
//
//  Created by Noah Johann on 01.12.25.
//

import SwiftUI
import Defaults
import JochexUI
import Luminare

struct SettingsLockScreenView: View {
    @Default(.lockExtension) private var lockExtension
    @Default(.lockSound) private var lockSound
    @Default(.unlockSound) private var unlockSound
    @Default(.lockPlayer) private var lockPlayer
    @Default(.lockPosition) private var lockPosition
    @Default(.alwaysShowPlayer) private var alwaysShowPlayer
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $lockExtension) {
                Image(systemName: "lock.fill")
                    .bold()
                    .foregroundStyle(lockExtension ? Color.accentColor : .secondary)
                Text("Enable LockScreen icon")
            }
            
            LuminareToggle(isOn: $lockSound) {
                Text("Play lock sound")
                Spacer()
                SettingsSoundItemView(sound: .lock)
            }
            
            LuminareToggle(isOn: $unlockSound) {
                Text("Play unlock sound")
                Spacer()
                SettingsSoundItemView(sound: .unlock)
            }
        }
        
        LuminareSection {
            LuminareToggle(isOn: $lockPlayer) {
                Image(systemName: "lock.rectangle.on.rectangle.fill")
                    .bold()
                    .foregroundStyle(lockPlayer ? Color.accentColor : .secondary)
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
            
            LuminareToggle(isOn: $alwaysShowPlayer) {
                Text("Always show player")
            }
        }
    }
}

#Preview {
    SettingsLockScreenView()
}
