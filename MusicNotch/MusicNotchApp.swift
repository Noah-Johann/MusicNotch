//
//  MusicNotchApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import SwiftUI
import KeyboardShortcuts
import Defaults

var notchState: String = "hide"

@main
struct MusicNotchApp: App {
    
    @State private var showMenuBarIcon: Bool = true
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @Default(.showMenuBarItem) private var showMenuBarItem
    
    init() {
        appSetup()
                
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
        
        showOnboarding()
        
        KeyboardShortcuts.onKeyDown(for: .toggleNotch) {
            NotchManager.shared.changeNotch()
        }
        
        timer = 0
    }
    
    var body: some Scene {
        MenuBarExtra("MusicNotch", image: "notch.square", isInserted: Binding(get: {
            showMenuBarItem
        }, set: { _ in })) {
            MenuBarExtraView()
        }
    }

    func appSetup() {
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
        SpotifyManager.shared.updateInfo()
    }
}
