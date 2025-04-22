//
//  MenuBarExtraView.swift
//  MusicNotch
//
//  Created by Noah Johann on 22.04.25.
//

import SwiftUI
import Luminare

struct MenuBarExtraView: View {
    var body: some View {
        Section {
            Button {
                spotifyPlayPause()
            } label: {
                Image(systemName: "play.fill")
                Text("Play")
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
                let aboutWindow = LuminareWindow(blurRadius: 20) {
                    aboutView()
                        .frame(width: 300, height: 380)
                }
                
                aboutWindow.center()
                aboutWindow.level = .floating
                aboutWindow.show()
            }
            
            Button("Settings") {
                let settingsWindow = LuminareWindow(blurRadius: 20) {
                    SettingsView()
                        .frame(width: 500, height: 600)
                }
                
                settingsWindow.center()
                settingsWindow.show()
                
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
