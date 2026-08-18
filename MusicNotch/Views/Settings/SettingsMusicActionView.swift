//
//  SettingsMusicActionView.swift
//  MusicNotch
//
//  Created by Noah Johann on 12.06.26.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsMusicActionView: View {    
    var body: some View {
        LuminareSection {
            LuminarePicker(
                elements: MusicAction.allCases,
                selection: Binding(
                    get: { Defaults[.musicAction]},
                    set: { Defaults[.musicAction] = $0 }
                ),
                columns: 2
                ) { option in
                    VStack(spacing: 6) {
                        option.image
                            .scaledToFit()
                            .frame(width: 30, height: 40)
                        Text(option.title)
                            .font(.title3)
                    }
                }
                .luminareRoundingBehavior(top: true, bottom: true)
                .luminareBorderedStates(.hovering)
                .buttonStyle(.luminare)
                .frame(height: 75)
        } header: {
            Text("Music Action")
        }
    }
}

#Preview {
    SettingsMusicActionView()
}
