//
//  SettingsAcknowledgementsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.04.25.
//

import SwiftUI
import Luminare

struct SettingsAcknowledgementsView: View {
    @State var showAcknowledgements: Bool = false
    
    var body: some View {
        VStack {
            LuminareSection {
                Button {
                    showAcknowledgements = !showAcknowledgements
                } label: {
                    HStack {
                        Image(systemName: showAcknowledgements == true ? "arrow.uturn.up.circle" : "arrow.uturn.down.circle")
                            .imageScale(.large)
                        Text(showAcknowledgements == true ? "Hide acknowledgements" : "Show acknowledgements")
                    }
                } .buttonStyle(LuminareButtonStyle())
                    .frame(height: 40)
                
                if showAcknowledgements == true {
                    aboutLicenseButton(name: "Luminare",
                                       license: "BSD 3-Clause",
                                       link: URL(string: "https://github.com/MrKai77/Luminare/tree/main")!,
                                       image: "book"
                    ) .frame( height: 40)
                    aboutLicenseButton(name: "DynamicNotchKit",
                                       license: "MIT",
                                       link: URL(string: "https://github.com/MrKai77/DynamicNotchKit")!,
                                       image: "book"
                    ) .frame( height: 40)
                    aboutLicenseButton(name: "KeyboardShortcuts",
                                       license: "MIT",
                                       link: URL(string: "https://github.com/sindresorhus/KeyboardShortcuts")!,
                                       image: "book"
                    ) .frame( height: 40)
                    aboutLicenseButton(name: "LaunchAtLogin",
                                       license: "MIT",
                                       link: URL(string: "https://github.com/sindresorhus/LaunchAtLogin-Modern")!,
                                       image: "book"
                    ) .frame( height: 40)
                    aboutLicenseButton(name: "Defaults",
                                       license: "MIT",
                                       link: URL(string: "https://github.com/sindresorhus/Defaults")!,
                                       image: "book"
                    ) .frame( height: 40)
                    aboutLicenseButton(name: "Custom Slider Control",
                                       license: "MIT",
                                       link: URL(string: "https://github.com/pratikg29/Custom-Slider-Control")!,
                                       image: "book"
                    ) .frame( height: 40)                        }
            } header: {
                Text ("Acknowledgements")
            }
            Text(Bundle.main.copyright)
                .padding()
                .font(.caption)
                .foregroundStyle(.secondary)
            
        } .animation(.easeInOut(duration: 0.2), value: showAcknowledgements)
    }
}

#Preview {
    SettingsAcknowledgementsView()
}
