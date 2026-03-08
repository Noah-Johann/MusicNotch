//
//  SettingsDisplayView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsDisplayView: View {
    @Default(.display) private var screen
    @Default(.transparentNotch) private var transparentNotch
    
    var body: some View {
        LuminareSection {
            LuminarePicker(
                elements: Display.allCases,
                selection: Binding(
                    get: { Defaults[.display] },
                    set: { Defaults[.display] = $0 }
                ),
                // .animation(LuminareConstants.animation),
                columns: 2
            ) { option in
                VStack(spacing: 6) {
                    option.image
                        .scaledToFit()
                        .frame(width: 30, height: 40)
                    Text(option.text)
                        .font(.title3)
                }
            }
            .luminareRoundingBehavior(top: true)
            .luminareBorderedStates(.none)
            .buttonStyle(.luminare)
            .frame(height: 80)
            LuminareToggle(isOn: $transparentNotch) {
                Text("Hide closed notch")
            }
        } header: {
            Text("Display")
        }
        .padding(.bottom, 14)
        .onChange(of: screen) {
            Task { @MainActor in
                await NotchManager.shared.setNotchState(.compact, changeDisplay: true)
            }
        }
    }
}

#Preview {
    SettingsDisplayView()
}
