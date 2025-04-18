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
    @Default(.notchSizeChange) private var notchSizeChange
    @Default(.viewedOnboarding) private var viewedOnboarding
    @Default(.openNotchOnHover) private var openNotchOnHover
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
                
                
                LuminareSection("Notch") {
                    
                    LuminareToggle("Open Notch on Hover", isOn: $openNotchOnHover)
                    
                    LuminareValueAdjuster("Notch Size Change",
                                          value: $notchSizeChange,
                                          sliderRange: -5...5.0,
                                          suffix:"px",
                                          step: 1.0)
                    
                    LuminareValueAdjuster("Hide Notch Time",
                                          value: $hideNotchTime,
                                          sliderRange: 1...15,
                                          suffix:"s",
                                          step: 1)
                } .padding(.bottom, 14)
                
                LuminareSection("Keyboard Shortcuts") {
                        KeyboardShortcuts.Recorder("Toggle Notch",
                                                   name: .toggleNotch)
                        .frame(height: 30)
                    
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
                            HStack (alignment: .center){
                                Image(systemName: showAcknowledgements == true ? "arrow.uturn.up.circle" : "arrow.uturn.down.circle")
                                    .imageScale(.large)
                                Text(showAcknowledgements == true ? "Hide Acknowledgements" : "Show Acknowledgements")
                                    .frame(width: 160, alignment: .center)
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
                    
                } .animation(.easeInOut(duration: 0.2))

            } .padding(.horizontal, 5)
        }
    }
    

    
    
}
#Preview {
    SettingsView()
}
