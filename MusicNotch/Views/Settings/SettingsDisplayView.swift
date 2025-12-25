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
    @Default(.mainDisplay) private var mainDisplay
    @Default(.transparentNotch) private var transparentNotch
    
    var body: some View {
        LuminareSection {
            DisplayPickerView()
                .buttonStyle(LuminareButtonStyle())
                .frame(height: 80)
                .padding(3)
            LuminareToggle(isOn: $transparentNotch) {
                Text("Hide closed notch")
            }
        } header: {
            Text("Display")
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsDisplayView()
}
