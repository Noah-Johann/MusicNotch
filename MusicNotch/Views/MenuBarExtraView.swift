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
    @ObservedObject var updateManager = UpdateManager.shared
    
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
                switch Defaults[.musicPlayer] {
                case .appleMusic:
                    Defaults[.musicPlayer].image.imageScale(.large)
                    Text("Show in Apple Music")
                case .spotify:
                    Defaults[.musicPlayer].image.imageScale(.large)
                    Text("Show in Spotify")
                case .nowPlaying:
                    if MusicManager.shared.playingAppBundle != nil {
                        getMusicAppImage(bundle: MusicManager.shared.playingAppBundle!).imageScale(.large)
                    } else {
                        Defaults[.musicPlayer].image.imageScale(.large)
                    }
                    if MusicManager.shared.playingAppName != nil {
                        Text("Show in \(MusicManager.shared.playingAppName ?? "Now Playing")")
                    } else {
                        Text("Show in Now Playing")
                    }
                }
            }
            
        }
        Section {
            Text("Version \(Bundle.main.appVersion!)")
                .foregroundStyle(.secondary)
            
            Button("About") {
                WindowManager.openAbout()
            }
            
            Button("Settings") {
                WindowManager.openSettings()
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
            Button("Quit", role: .destructive) {
                NSApp.terminate(nil)
            } .keyboardShortcut("Q", modifiers: .command)
            
        }
    }
}

