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
                let aboutWindow = LuminareWindow() {
                    aboutView()
                        .frame(width: 300, height: 380)
                }
                
                aboutWindow.center()
                aboutWindow.level = .floating
                aboutWindow.makeKeyAndOrderFront(nil)
            }
            
            Button("Settings") {
                let settingsWindow = LuminareWindow() {
                    SettingsView()
                        .frame(width: 500, height: 600)
                }
                
                settingsWindow.center()
                settingsWindow.makeKeyAndOrderFront(nil)
                
            } .keyboardShortcut(.init(",", modifiers: [.command]))
        }
        Section {
            Button("Quit", role: .destructive) {
                NSApp.terminate(nil)
            } .keyboardShortcut("Q", modifiers: .command)
            
        }
    }
}

#Preview {
    MenuBarExtraView()
}
