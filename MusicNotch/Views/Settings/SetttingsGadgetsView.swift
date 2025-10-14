//
//  SetttingsGadgetsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.10.25.
//

import SwiftUI
import Luminare
import Defaults

struct SetttingsGadgetsView: View {
    @Default(.activateGadgets) private var activateGadgets
    @Default(.batteryGadget) private var batteryGadget
    @Default(.settingsGadget) private var settingsGadget
    
    var body: some View {
        LuminareSection() {
            LuminareToggle(isOn: $activateGadgets) {
                Text("Activate Gadgets")
            }
            if activateGadgets {
                GadgetsPickerView()

                LuminareToggle(isOn: $settingsGadget) {
                    Text("Settings Gadget")
                }
                LuminareToggle(isOn: $batteryGadget) {
                    Text("Battery Gadget")
                }
            }
        } header: {
            Text("Gadgets")
        } .animation(.easeInOut(duration: 0.2), value: activateGadgets)
    }
}

#Preview {
    SetttingsGadgetsView()
}
