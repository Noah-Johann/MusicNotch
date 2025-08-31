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
    @Default(.disableNotchOnHide) private var disableNotchOnHide
    @Default(.noNotchScreenHide) private var noNotchScreenHide
    
    var body: some View {
        LuminareSection {
            DisplayPickerView()
                .buttonStyle(LuminareButtonStyle())
                .frame(height: 80)
                .padding(3)
            if mainDisplay == true {
                LuminareToggle(isOn: $disableNotchOnHide) {
                    Text("Hide fake notch")
                        .padding(.trailing, 5)
                        .luminarePopover(attachedTo: .topTrailing) {
                            Text("If active, the notch can't be opened when nothing is playing")
                                .padding()
                        }
                        .tint(.accentColor)
                }
            } else {
                LuminareToggle(isOn: $noNotchScreenHide) {
                    Text("Disable Notch on external Screens")
                        .padding(.trailing, 5)
                        .luminarePopover(attachedTo: .topTrailing) {
                            Text("Disable notch when there is no Notch Display")
                                .padding()
                        }
                        .tint(.accentColor)
                }
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
