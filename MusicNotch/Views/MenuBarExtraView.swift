//
//  MenuBarExtraView.swift
//  MusicNotch
//
//  Created by Noah Johann on 22.04.25.
//

import SwiftUI
import Luminare
import Defaults

struct MenuBarExtraView: View {    
    @State var musicManager = MusicManager.shared
    @State var updateManager = UpdateManager.shared
    
    @Default(.autoPlayer) private var autoPlayer
    @Default(.musicPlayer) private var musicPlayer
    
    var body: some View {
        Section {
            Button {
                MusicActions.playPause()
            } label: {
                Label(musicManager.music.isPlaying == true ? "Pause" : "Play", systemImage: musicManager.music.isPlaying == true ? "pause.fill" : "play.fill")
            }
            
            Button {
                MusicActions.nextTrack()
            } label: {
                Label("Next", systemImage: "forward.end.fill")
            }
            
            Button {
                MusicActions.lastTrack()
            } label: {
                Label("Previous", systemImage: "backward.end.fill")
            }
            
            Button {
                openMusicApp()
            } label: {
                switch MusicManager.shared.musicPlayer {
                case .appleMusic:
                    Label {
                        Text("Show in Apple Music")
                    } icon: {
                        musicManager.musicPlayer.image.imageScale(.large)
                    }
                case .spotify:
                    Label {
                        Text("Show in Spotify")
                    } icon: {
                        musicManager.musicPlayer.image.imageScale(.large)
                    }
                case .nowPlaying:
                    Label {
                        if let name = MusicManager.shared.playingAppName {
                            Text("Show in \(name)")
                        } else {
                            Text("Show in Now Playing")
                        }
                    } icon: {
                        if let bundle = MusicManager.shared.playingAppBundle {
                            getMusicAppImage(bundle: bundle).imageScale(.large)
                        } else {
                            MusicManager.shared.musicPlayer.image.imageScale(.large)
                        }
                    }
                }
            }
        } .labelStyle(.titleAndIcon)
        
        if !autoPlayer {
            Section {
                Picker("Source", selection: $musicPlayer) {
                    ForEach(MusicApp.allCases, id: \.self) { app in
                        Label {
                            Text(app.text)
                        } icon: {
                            app.image.imageScale(.large)
                        } .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
        
        Section {
            Text("Version \(Bundle.main.appVersion!)")
                .foregroundStyle(.secondary)
            
            Button("About") {
                Task {
                    WindowManager.shared.openAbout()
                }
            }
            
            Button("Settings") {
                Task {
                    WindowManager.shared.openSettings()
                }
            } .keyboardShortcut(.init(",", modifiers: [.command]))
        }
        
        Section {
            Button {
                switch updateManager.updateState {
                case .idle, .checking, .error, .installed, .noUpdates:
                    updateManager.checkForUpdates(fromMenuBar: true)
                case .updateAvailable:
                    updateManager.downloadUpdate()
                case .readyToInstall:
                    updateManager.installUpdate()
                case .installing, .downloading, .extracting:
                    print("fix")
                }
            } label: {
                switch updateManager.updateState {
                case .idle, .checking, .error:
                    Text("Check for updates")
                case .noUpdates:
                    Text("No updates available")
                case .updateAvailable:
                    Text("Download update")
                case .downloading, .extracting:
                    Text("Downloading update...")
                case .readyToInstall:
                    Text("Install update")
                case .installing, .installed:
                    Text("Installing update...")
                }
            }
        } .onAppear {
            if updateManager.updateState == .noUpdates {
                updateManager.updateState = .idle
            }
        }
        Section {
            if #available(macOS 15, *) {
                Button("Quit", role: .destructive) {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("Q", modifiers: .command)
                .modifierKeyAlternate(.option) {
                    Button("Restart", role: .destructive) {
                        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }

                        let workspace = NSWorkspace.shared

                        guard let appURL = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) else { return }

                        let configuration = NSWorkspace.OpenConfiguration()
                        configuration.createsNewApplicationInstance = true

                        workspace.openApplication(at: appURL, configuration: configuration, completionHandler: nil)
                        NSApplication.shared.terminate(nil)
                    }
                }
            }
            else {
                Button("Quit", role: .destructive) {
                    NSApp.terminate(nil)
                } .keyboardShortcut("Q", modifiers: .command)
            }
        }
    }
}

