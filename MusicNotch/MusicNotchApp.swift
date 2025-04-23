//
//  MusicNotchApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import SwiftUI
import KeyboardShortcuts

var notchState: String = "hide"

@main
struct MusicNotchApp: App {
    
   // static var MusicNotch: DynamicNotch<AnyView, AnyView, AnyView>? = nil
    @State private var showMenuBarIcon: Bool = true
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    
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
                
        MenuBarExtra("MusicNotch", image: "notch.square", isInserted: $showMenuBarIcon) {
            MenuBarExtraView()
        }
    }

    func appSetup() {
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
        SpotifyManager.shared.updateInfo()
    }
}
