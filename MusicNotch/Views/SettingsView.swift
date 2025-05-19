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
import KeyboardShortcuts

struct SettingsView: View {
    
    @Default(.hideNotchTime) private var hideNotchTime
    @Default(.viewedOnboarding) private var viewedOnboarding
    @Default(.openNotchOnHover) private var openNotchOnHover
    @Default(.openingDelay) private var openingDelay
    @Default(.hapticFeedback) private var hapticFeedback
    @Default(.mainDisplay) private var mainDisplay
    @Default(.disableNotchOnHide) private var disableNotchOnHide
    @Default(.showMenuBarItem) private var showMenuBarItem
    
    @State var showAcknowledgements = false

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
                    LuminareToggle("Show menubar item",
                                   info: LuminareInfoView (
                                    "If hidden, settings can be accesed via right click on the player",
                                        .accentColor
                                   ),
                                   isOn: $showMenuBarItem)
                    #if DEBUG
                    LuminareToggle("Viewed Onboarding", isOn: $viewedOnboarding)
                    #endif
                    
                    
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        HStack {
                            Image(systemName: "power")
                            Text("Quit")
                        }
                    } .buttonStyle(LuminareButtonStyle())
                } .padding(.bottom, 14)
                
                LuminareSection("Display") {
                    DisplayPickerView()
                        .buttonStyle(LuminareButtonStyle())
                        .frame(height: 80)
                    if mainDisplay == true {
                        LuminareToggle("Hide fake notch",
                                       info: LuminareInfoView (
                                        "If active, the notch can't be opened when nothing is playing",
                                        .accentColor
                                       ),
                                       isOn: $disableNotchOnHide)
                    }
                } .padding(.bottom, 14)
                
                LuminareSection("Notch") {
                    
                    LuminareToggle("Open Notch on hover", isOn: $openNotchOnHover)
                    
                    LuminareToggle("Haptic feedback", isOn: $hapticFeedback)
                    
                    if openNotchOnHover == true {
                        LuminareValueAdjuster("Opening delay",
                                              value: $openingDelay,
                                              sliderRange: 0...1,
                                              suffix: "s",
                                              step: 0.1,
                                              decimalPlaces: 1)
                    } 
                                       
                    LuminareValueAdjuster("Hide delay",
                                          info: LuminareInfoView(
                                            "The time it takes for the notch to hide if the playback is stopped.",
                                            .accentColor,
                                          ),
                                          value: $hideNotchTime,
                                          sliderRange: 0...15,
                                          suffix:"s",
                                          step: 1,
                    )
                } .padding(.bottom, 14)
                
                LuminareSection("Keyboard Shortcuts") {
                        KeyboardShortcuts.Recorder("Toggle Notch",
                                                   name: .toggleNotch)
                        .frame(height: 40)
                } .padding(.bottom, 14)
                
                LuminareSection("About") {
                    aboutAppButton()
                        .frame(height: 75)
                } .padding(.bottom, 7)
                
                LuminareSection() {
                    SettingsAboutView()
                } .padding(.bottom, 14)
                
                VStack {
                    LuminareSection("Acknowledgements") {
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
                            SettingsAcknowledgementsView()
                        }
                    }
                    Text(Bundle.main.copyright)
                        .padding()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                } .animation(.easeInOut(duration: 0.2), value: showAcknowledgements)


            } .padding(.horizontal, 5)
              .animation(.easeInOut(duration: 0.2), value: mainDisplay)

        }
    }
    

    
    
}
#Preview {
    SettingsView()
}
