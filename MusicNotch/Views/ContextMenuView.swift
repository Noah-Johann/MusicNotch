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
        AppDelegateHolder.shared?.showAboutWindow()
    }
    
    Button("Settings") {
        AppDelegateHolder.shared?.showSettingsWindow()
        
    } .keyboardShortcut(.init(",", modifiers: [.command]))
    
    Section {
        Button("Quit", role: .destructive) {
            NSApp.terminate(nil)
        } .keyboardShortcut("Q", modifiers: .command)
        
    }
    
    
}
