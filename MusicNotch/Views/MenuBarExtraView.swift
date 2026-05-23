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
                Image(systemName: musicManager.music.isPlaying == true ? "pause.fill" : "play.fill")
                Text(musicManager.music.isPlaying == true ? "Pause" : "Play")
            }
            
            Button {
                MusicActions.nextTrack()
            } label: {
                Image(systemName: "forward.end.fill")
                Text("Next")
            }
            Button {
                MusicActions.lastTrack()
            } label: {
                Image(systemName: "backward.end.fill")
                Text("Previous")
            }
            Button {
                openMusicApp()
            } label: {
                switch MusicManager.shared.musicPlayer {
                case .appleMusic:
                    MusicManager.shared.musicPlayer.image.imageScale(.large)
                    Text("Show in Apple Music")
                case .spotify:
                    MusicManager.shared.musicPlayer.image.imageScale(.large)
                    Text("Show in Spotify")
                case .nowPlaying:
                    if MusicManager.shared.playingAppBundle != nil {
                        getMusicAppImage(bundle: MusicManager.shared.playingAppBundle!).imageScale(.large)
                    } else {
                        MusicManager.shared.musicPlayer.image.imageScale(.large)
                    }
                    if MusicManager.shared.playingAppName != nil {
                        Text("Show in \(MusicManager.shared.playingAppName ?? "Now Playing")")
                    } else {
                        Text("Show in Now Playing")
                    }
                }
            }
            
        }
        
        if !autoPlayer {
            Section {
                Picker("Source", selection: $musicPlayer) {
                    ForEach(MusicApp.allCases, id: \.self) { app in
                        HStack {
                            app.image.imageScale(.large)
                            Text(app.text)
                        }
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

