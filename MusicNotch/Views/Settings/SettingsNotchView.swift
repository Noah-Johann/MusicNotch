//
//  SettingsNotchView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import JochexUI
import Defaults

struct SettingsNotchView: View {
    @Default(.hoverBehavior) private var hoverBehavior
    @Default(.hapticFeedback) private var hapticFeedback
    @Default(.openingDelay) private var openingDelay
    @Default(.hideNotchTime) private var hideNotchTime
    
    var body: some View {
        LuminareSection {
            LuminarePicker(
                elements: HoverBehavior.allCases,
                selection: Binding(
                    get: { Defaults[.hoverBehavior] },
                    set: { Defaults[.hoverBehavior] = $0 }
                ),
                // .animation(LuminareConstants.animation),
                columns: 3
            ) { option in
                HStack(spacing: 6) {
                    option.image
                        .imageScale(.large)
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                    Text(option.text)
                        .font(.title3)
                }
            }
            .luminareRoundingBehavior(top: true)
            .luminareBorderedStates(.hovering)
            .frame(height: 50)
            
            LuminareToggle(isOn: $hapticFeedback) {
                Text("Haptic feedback")
            }
            
            if hoverBehavior == .expand {
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
                Spacer()
                SettingsInfoItemView { Text("The time it takes for the notch to hide if the playback is stopped.") }
                
            }
            .luminareSliderLayout(.regular)
            .padding(.bottom, 5)
        } header: {
            Text("Hover Behavior")
        }
    }
}

#Preview {
    SettingsNotchView()
}
