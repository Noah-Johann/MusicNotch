//
//  MenuBarExtraView.swift
//  MusicNotch
//
//  Created by Noah Johann on 22.04.25.
//

import SwiftUI
import Luminare

struct MenuBarExtraView: View {    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    var body: some View {
        Section {
            Button {
                spotifyPlayPause()
            } label: {
                Image(systemName: spotifyManager.isPlaying == true ? "pause.fill" : "play.fill")
                Text(spotifyManager.isPlaying == true ? "Pause" : "Play")
            }
            
            Button {
                spotifyNextTrack()
            } label: {
                Image(systemName: "forward.end.fill")
                Text("Next")
            }
            Button {
                spotifyLastTrack()
            } label: {
                Image(systemName: "backward.end.fill")
                Text("Previous")
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
            Button("Check for updates") {
                UpdaterWrapper.shared.updaterController.checkForUpdates(nil)
            }
        }
        
        Section {
            Button("Quit", role: .destructive) {
                NSApp.terminate(nil)
            } .keyboardShortcut("Q", modifiers: .command)
            
        }
    }
}

