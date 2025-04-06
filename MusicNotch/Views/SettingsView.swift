//
//  SettingsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 27.03.25.
//

import Foundation
import SwiftUI
import Luminare
import Defaults
import LaunchAtLogin

struct SettingsView: View {
    
    @Default(.hideNotchTime) private var hideNotchTime
    @Default(.notchSizeChange) private var notchSizeChange
    


    var body: some View {
        LuminarePane {}
        content: {
            
            VStack {
                LuminareSection("General") {
                    LuminareToggle(
                        "Launch at login",
                        isOn: Binding(
                            get: { LaunchAtLogin.isEnabled },
                            set: { value in LaunchAtLogin.isEnabled = value }
                        )
                    )
                    
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        HStack {
                            Image(systemName: "power")
                            Text("Quit")
                        }
                    } .buttonStyle(LuminareButtonStyle())
                } .padding(.bottom, 14)
                
                
                LuminareSection("Notch") {
                    
                    LuminareValueAdjuster("Notch Size Change", value: $notchSizeChange, sliderRange: 0...5.0, suffix:"px", step: 1.0)
                    
                    LuminareValueAdjuster("Hide Notch when nothing is playing", value: $hideNotchTime, sliderRange: 1...15, suffix:"s", step: 1)
                } .padding(.bottom, 14)
                
                LuminareSection("About") {
                    
                    aboutAppButton()
                        .frame(height: 75)
                } .padding(.bottom, 7)
                
                LuminareSection() {
                    aboutButton(name: "Noah Johann",
                                role: "Development",
                                link: URL(string: "https://github.com/Noah-Johann")!,
                                image: Image("Credit")
                    ) .frame(height: 60)
                    
                    aboutButton(name: "GitHub",
                                role: "Contribute on Github",
                                link: URL(string: "https://github.com/Noah-Johann/MusicNotch")!,
                                image: Image("Github")
                    ) .frame( height: 60)
                } .padding(.bottom, 14)
                
                LuminareSection("Acknowledgements") {
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
                    ) .frame( height: 40)
                }
                
                Text(Bundle.main.copyright)
                    .padding()
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } .padding(.horizontal, 5)
        }
    }
    

    
    
}
#Preview {
    SettingsView()
}
