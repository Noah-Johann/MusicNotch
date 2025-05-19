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
    
    Section {
        Button("Quit", role: .destructive) {
            NSApp.terminate(nil)
        } .keyboardShortcut("Q", modifiers: .command)
        
    }
    
    
}
