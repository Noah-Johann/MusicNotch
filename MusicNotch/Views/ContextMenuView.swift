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
        WindowManager.openAbout()
    }
    
    Button("Settings") {
        WindowManager.openSettings()
        
    } .keyboardShortcut(.init(",", modifiers: [.command]))
    
    Section {
        Button("Quit", role: .destructive) {
            NSApp.terminate(nil)
        } .keyboardShortcut("Q", modifiers: .command)
        
    }
    
    
}
