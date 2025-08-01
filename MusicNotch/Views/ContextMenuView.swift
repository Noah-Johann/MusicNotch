//
//  ContextMenuView.swift
//  MusicNotch
//
//  Created by Noah Johann on 17.05.25.
//

import SwiftUI
import Luminare


@MainActor @ViewBuilder
func ContextMenuView() -> some View {
    
    Text("Version \(Bundle.main.appVersion!)")
        .foregroundStyle(.secondary)
    
    Button("About") {
        NotchManager.shared.setNotchContent(.closed, false)
        WindowManager.openAbout()
    }
    
    Button("Settings") {
        NotchManager.shared.setNotchContent(.closed, false)
        WindowManager.openSettings()
        
    } .keyboardShortcut(.init(",", modifiers: [.command]))
    
    Section {
        Button("Quit", role: .destructive) {
            NSApp.terminate(nil)
        } .keyboardShortcut("Q", modifiers: .command)
        
    }
    
    
}
