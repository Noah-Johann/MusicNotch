//
//  SettingsNotchView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsNotchView: View {
    @Default(.openNotchOnHover) private var openNotchOnHover
    @Default(.hapticFeedback) private var hapticFeedback
    @Default(.openingDelay) private var openingDelay
    @Default(.hideNotchTime) private var hideNotchTime
    
    var body: some View {
        LuminareSection {
            
            LuminareToggle(isOn: $openNotchOnHover) {
                Text("Open Notch on hover")
            }
            
            LuminareToggle(isOn: $hapticFeedback) {
                Text("Haptic feedback")
            }
            
            if openNotchOnHover == true {
                LuminareSlider(
                    value: $openingDelay,
                    in: 0...1,
                    format: .number.precision(.fractionLength(0...1)),
                    suffix: Text("s")
                    
                ) {
                    Text("Opening delay")
                }
                .luminareSliderLayout(.regular)
                .padding(.bottom, 3)
            }
            
            LuminareSlider(
                value: $hideNotchTime,
                in: 0...15,
                step: 1,
                format: .number.precision(.fractionLength(0)),
                suffix: Text("s")
                
            ) {
                Text("Hide delay")
                    .padding(.trailing, 5)
                    .luminarePopover(attachedTo: .topTrailing) {
                        Text("The time it takes for the notch to hide if the playback is stopped.")
                            .padding()
                    }
                
            }
            .luminareSliderLayout(.regular)
            .padding(.bottom, 5)
        } header: {
            Text("Notch")
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsNotchView()
}
