//
//  SettingsAboutView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.04.25.
//

import SwiftUI
import Luminare
import JochexUI
import Defaults

struct SettingsAboutView: View {
    
    @State private var updateManager = UpdateManager.shared
    
    private let profileURL: String = "https://github.com/Noah-Johann"
    private let projectURL: String = "https://github.com/Noah-Johann/MusicNotch"
    private let releaseNotes: String = "https://github.com/Noah-Johann/MusicNotch/releases/latest"
    private let licenseURL: String = "https://github.com/Noah-Johann/MusicNotch/blob/main/LICENSE"
    private let acknowledgementsURL: String = "https://github.com/Noah-Johann/MusicNotch/blob/main/Acknowledgments.md"
    
    var showReleaseNotes: Bool {
        if updateManager.updateState == .updateAvailable || updateManager.updateState == .downloading || updateManager.updateState == .extracting {
            return true
        } else {
            return false
        }
    }
    
    @State private var updateProgress: CGFloat = 0
    
    @Default(.autoUpdates) private var autoUpdates

    var body: some View {
        
// MARK: - About Section
        VStack(spacing: 0) {
            Button {
                copyInfo(text: "MusicNotch Version \(Bundle.main.appVersion ?? "0") (\(Bundle.main.appBuild ?? 0))")
            } label: {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .padding(-3)
            } .buttonStyle(ScalingPlainButtonStyle(downScale: 0.9))
            
            VStack(spacing: 0) {
                Text(Bundle.main.appName)
                    .blur(radius: 0)
                    .foregroundStyle(.primary)
                    .font(.system(size: 29, weight: .bold))
                Text("Version \(Bundle.main.appVersion ?? "0") (\(Bundle.main.appBuild ?? 0))")
                    .foregroundStyle(Color(.tertiaryLabelColor))
                    .font(.body)
                    .padding(.top, 5)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
        }
        
        
// MARK: - Update Button
        JochexSection {
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
                    }
                    
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
                    }
                    
                case .updateAvailable:
                    Button {
                        updateManager.downloadUpdate()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .imageScale(.large)
                            Text("Download update")
                            Spacer()
                            
                            Text("v\(updateManager.newVersionNumber)")
                                .foregroundStyle(.secondary)
                                .monospaced()
                        } .padding()
                    }
                    
                case .downloading, .extracting:
                    Button {} label: {
                        HStack {
                            HudSlider(value: $updateManager.updateProgress, height: 6)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical)
                    }

                    
                case .readyToInstall:
                    Button {
                        updateManager.installUpdate()
                    } label: {
                        HStack (spacing: 12) {
                            Image(systemName: "gear.badge")
                            Text("Install update")
                            Spacer()
                        } .padding()
                    }
                    
                case .installing:
                    Button {} label: {
                        HStack (spacing: 12) {
                            Image(systemName: "gear.badge")
                            Text("Install update")
                            Spacer()
                        }
                    }
                    
                case .installed:
                    Button {} label: {
                        Text("Installed update")
                    }
                }
            }
            .frame(height: 36)
            .luminareRoundingBehavior(bottom: !showReleaseNotes)
            .luminareBorderedStates(.none)
            .buttonStyle(.luminare)
            
            if showReleaseNotes {
                Button {
                    NSWorkspace.shared.open(URL(string: releaseNotes)!)
                } label: {
                    HStack (spacing: 12) {
                        Image(systemName: "document.badge.gearshape")
                            .imageScale(.large)
                        Text("Release Notes")
                        Spacer()
                        Image(systemName: "arrow.up")
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.luminare)
                .frame(height: 36)
            }
        } 
            .onChange(of: updateManager.updateState) {
                if updateManager.updateState == .noUpdates {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        updateManager.updateState = .idle
                    }
                } else { return }
            }
        
// MARK: - About section

        JochexSection {
            CosmeticTwoLineButton(heading: "Noah Johann",
                                  description: "Development",
                                  image: Image("Credit"),
                                  hoverIcon: "arrow.up.right",
                                  circleOverlay: true)
            { NSWorkspace.shared.open(URL(string: profileURL)!) }
                .luminareRoundingBehavior(top: true)
            
            CosmeticTwoLineButton(heading: "GitHub",
                                  description: "Contribute on Github",
                                  image: Image("Github"),
                                  hoverIcon: "arrow.up.right",
                                  circleOverlay: true)
            { NSWorkspace.shared.open(URL(string: projectURL)!) }
                .luminareRoundingBehavior(bottom: true)
        }
        
        JochexSection {
            CosmeticOneLineButton(title: "License", image: Image(systemName: "list.bullet.clipboard"), hoverIcon: "arrow.up.right") {
                NSWorkspace.shared.open(URL(string: licenseURL)!)
            } .luminareRoundingBehavior(top: true)
            
            CosmeticOneLineButton(title: "Acknowledgements", image: Image(systemName: "list.bullet.clipboard"), hoverIcon: "arrow.up.right") {
                NSWorkspace.shared.open(URL(string: acknowledgementsURL)!)
            } .luminareRoundingBehavior(bottom: true)
        }
        
        Text(Bundle.main.copyright)
            .padding()
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    SettingsAboutView()
}
