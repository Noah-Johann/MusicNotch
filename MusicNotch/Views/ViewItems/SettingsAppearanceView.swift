//
//  SettingsApearanceView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsApearanceView: View {
    @Default(.coloredSpect) private var coloredSpect
    
    var body: some View {
        LuminareSection {
            LuminareToggle(isOn: $coloredSpect) {
                Text("Colored spectogram")
            }
            
        } header: {
            Text("Apearance")
        }
        .padding(.bottom, 14)    }
}

#Preview {
    SettingsApearanceView()
}
