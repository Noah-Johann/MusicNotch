//
//  SettingsAboutView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.04.25.
//

import SwiftUI
import Luminare
import Defaults

struct SettingsAboutView: View {
    
    @StateObject private var updateManager = UpdateManager.shared
    
    private let releaseNotes: String = "https://github.com/Noah-Johann/MusicNotch/releases/latest"
    
    @State private var updateProgress: CGFloat = 0
    
    @Default(.autoUpdates) private var autoUpdates

    var body: some View {
        
// MARK: About Button
        LuminareSection {
            aboutAppButton()
                .frame(height: 75)
        } header: {
            Text("About")
        }.padding(.bottom, 7)
        
        
// MARK: Update Button
        LuminareSection {
            LuminareToggle(isOn: $autoUpdates) {
                Text ("Auto check for updates")
            } .onChange(of: autoUpdates) {
                updateManager.updateAutoSettings()
            }

            VStack {
                switch updateManager.updateState {
                case .idle, .error, .checking:
                    Button {
                        updateManager.checkForUpdates()
                    } label: {
                        HStack (spacing: 12){
                            Image(systemName: "arrow.down.app")
                                .imageScale(.large)
                            Text("Check for updates")
                            Spacer()
                        } .padding()
                    } .buttonStyle(LuminareButtonStyle())
                    
                case .noUpdates:
                    Button {
                        updateManager.checkForUpdates()
                    } label: {
                        HStack (spacing: 12) {
                            Image(systemName: "xmark.app")
                                .imageScale(.large)
                            Text("No updates available")
                            Spacer()
                        } .padding()
                    }  .buttonStyle(LuminareButtonStyle())
                    
                case .updateAvailable:
                    Button {
                        updateManager.downloadUpdate()
                    } label: {
                        HStack {
                            Text("Download update")
                            
                            Spacer()
                            
                            Text("v\(updateManager.newVersionNumber)")
                                .foregroundStyle(.secondary)
                                .monospaced()
                        } .padding()
                    }  .buttonStyle(LuminareButtonStyle())
                    
                case .downloading, .extracting:
                    Button {} label: {
                        HStack {
                            HudSlider(value: $updateManager.updateProgress, isExpanded: true)
                        }
                        .padding(. horizontal, 25)
                        .padding(.vertical)
                    }  .buttonStyle(LuminareButtonStyle())

                    
                case .readyToInstall:
                    Button {
                        updateManager.installUpdate()
                    } label: {
                        HStack (spacing: 12) {
                            Image(systemName: "gear.badge")
                            Text("Install update")
                            Spacer()
                        } .padding()
                    }  .buttonStyle(LuminareButtonStyle())
                    
                case .installing:
                    Button {} label: {
                        HStack (spacing: 12) {
                            Image(systemName: "gear.badge")
                            Text("Install update")
                            Spacer()
                        }
                    }  .buttonStyle(LuminareButtonStyle())
                    
                case .installed:
                    Button {} label: {
                        Text("Installed update")
                    }  .buttonStyle(LuminareButtonStyle())
                }
            } .frame(height: 36)
            
            if updateManager.updateState == .updateAvailable {
                Button {
                    NSWorkspace.shared.open(URL(string: releaseNotes)!)
                } label: {
                    HStack (spacing: 12) {
                        Image(systemName: "document.badge.gearshape")
                            .imageScale(.large)
                        Text("Release Notes")
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(LuminareCosmeticButtonStyle(icon: Image(systemName: "arrow.up.right")))
                .frame(height: 36)
            }
        } .animation(.easeInOut(duration: 0.3), value: updateManager.updateState)
            .animation(.bouncy(duration: 0.2), value: updateManager.updateProgress)
            .onChange(of: updateManager.updateState) {
                if updateManager.updateState == .noUpdates {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        updateManager.updateState = .idle
                    }
                } else { return }
            }


        LuminareSection {
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
        }
        .padding(.bottom, 14)
    }
}

#Preview {
    SettingsAboutView()
}
