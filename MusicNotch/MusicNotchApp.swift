//
//  MusicNotchApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import SwiftUI
import DynamicNotchKit
import KeyboardShortcuts

@main
struct MusicNotchApp: App {
    static var MusicNotch: DynamicNotch<AnyView>? = nil // Make it a static property
    
    init() {
        appSetup()
        timer = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            MusicNotchApp.showNotch()
        }
        
        for i in 0...30 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1) {
                MusicNotchApp.showDynamicNotch()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            OpendPlayer()
        }
        Settings {
            SettingsView()
        }
    }
    
    static func showDynamicNotch() {
        if MusicNotch == nil {
            MusicNotch = DynamicNotch(style: .notch) {
                AnyView(OpendPlayer()) // Ensure uniform return type
            }
        }
        
        print(timer)
        
        if timer == 20 {
            print("Change content")
            
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(closedPlayer()) }
            }
        }
        if timer == 25 {
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(OpendPlayer()) }
            }
        }
    }
    
    static func showOnNotchScreen() {
        guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
            print("No notch screen found")
            MusicNotch?.show(on: NSScreen.screens.first!)
            return
        }
        
        DispatchQueue.main.async {
            MusicNotch?.show(on: notchScreen)
        }
    }

    static func showNotch() {
        showOnNotchScreen()
        print("showNotch called")
    }
    
    func appSetup() {
        requestAllPermissions()
        SpotifyManager.shared.startAutoUpdate(withInterval: 1)
        print(SpotifyManager.shared.trackName)
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
    }
}
