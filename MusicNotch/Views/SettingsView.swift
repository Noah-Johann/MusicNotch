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
        LuminarePane() {
            VStack {
                LuminareSection {
                    LuminareToggle(
                        isOn: Binding(
                            get: { LaunchAtLogin.isEnabled },
                            set: { value in LaunchAtLogin.isEnabled = value }
                        )
                    ) {
                        Text("Launch at login")
                    }
                    LuminareToggle(isOn: $showMenuBarItem) {
                        Text("Show menubar item")
                            .padding(.trailing, 5)
                            .luminarePopover(attachedTo: .topTrailing) {
                                Text("If hidden, settings can be accesed via right click on the player")
                                    .padding()
                            }
                            .tint(.accentColor)
                    }
                    
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
                } header: {
                    Text("General")
                }
                .padding(.bottom, 14)
                
                LuminareSection {
                    DisplayPickerView()
                        .buttonStyle(LuminareButtonStyle())
                        .frame(height: 80)
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
                    }
                } header: {
                    Text("Display")
                }
                .padding(.bottom, 14)
                
                LuminareSection {
                    
                    LuminareToggle(isOn: $openNotchOnHover) {
                        Text("Open Notch on hover")
                    }
                    
                    LuminareToggle(isOn: $hapticFeedback) {
                        Text("Haptic feedback")
                    }
                    
                    if openNotchOnHover == true {
                        LuminareSlider(
                            value: $openingDelay,
                            in: 0...1,
                            format: .number.precision(.fractionLength(0...1)),
                            suffix: Text("s")
                            
                        ) {
                            Text("Opening delay")
                        }
                        .luminareSliderLayout(.regular)
                    }
                    
                    LuminareSlider(
                        value: $hideNotchTime,
                        in: 0...15,
                        format: .number.precision(.fractionLength(0)),
                        suffix: Text("s")
                        
                    ) {
                        Text("Hide delay")
                            .padding(.trailing, 5)
                            .luminarePopover(attachedTo: .topTrailing) {
                                Text("The time it takes for the notch to hide if the playback is stopped.")
                                    .padding()
                            }
                        
                    }
                    .luminareSliderLayout(.regular)
                } header: {
                    Text("Notch")
                }
                .padding(.bottom, 14)
                
                LuminareSection {
                    KeyboardShortcuts.Recorder("Toggle Notch",
                                               name: .toggleNotch)
                    .frame(height: 40)
                } header: {
                    Text("Keyboard shortcuts")
                }
                .padding(.bottom, 14)
                
                
                LuminareSection {
                    aboutAppButton()
                        .frame(height: 75)
                } header: {
                    Text("About")
                }.padding(.bottom, 7)
                
                LuminareSection {
                    SettingsAboutView()
                }
                .padding(.bottom, 14)
                
                
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
                            SettingsAcknowledgementsView()
                        }
                    } header: {
                        Text ("Acknowledgements")
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
