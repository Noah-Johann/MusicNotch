//
//  ContextMenuView.swift
//  MusicNotch
//
//  Created by Noah Johann on 17.05.25.
//

import SwiftUI
import Luminare


@ViewBuilder
func ContextMenuView() -> some View {
    
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
    
    Section {
        Button("Quit", role: .destructive) {
            NSApp.terminate(nil)
        } .keyboardShortcut("Q", modifiers: .command)
        
    }
    
    
}
