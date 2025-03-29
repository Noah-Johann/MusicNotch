//
//  MusicNotchApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import SwiftUI
import DynamicNotchKit
import KeyboardShortcuts

var notchState: String = "hide"

@main
struct MusicNotchApp: App {
    static var MusicNotch: DynamicNotch<AnyView>? = nil // Make it a static property
    @State private var appState = AppState()
    @State private var showMenuBarIcon: Bool = true
    
    init() {
        appSetup()
        timer = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            MusicNotchApp.showNotch()
        }
    }
    
    var body: some Scene {
        MenuBarExtra("boring.notch", systemImage: "music.note.tv", isInserted: $showMenuBarIcon) {
            Button("About MusicNotch") {
                NSApp.orderFrontStandardAboutPanel()
            }
            SettingsLink(label: {
                Text("Settings")
            })
            Button("Quit", role: .destructive) {
                NSApp.terminate(nil)
            }
        }
        Settings {
            SettingsView()
        }
    }
    
    static func showOnNotchScreen() {
        guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
            print("No notch screen found")
            MusicNotch?.show(on: NSScreen.screens.first!)
            NSApp.setActivationPolicy(.accessory)
            return
        }
        
        DispatchQueue.main.async {
            MusicNotch?.show(on: notchScreen) }
        NSApp.setActivationPolicy(.accessory)

    }

    static func showNotch() {
        
        if MusicNotch == nil {
            MusicNotch = DynamicNotch(style: .notch) {
                AnyView(closedPlayer()) }
            notchState = "closed"
        }
        
        showOnNotchScreen()
    }
    
    static func changeNotch() {
        if notchState == "closed" {
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(OpendPlayer()) }
            }
            notchState = "open"
        } else if notchState == "open" {
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(closedPlayer()) }
            }
            notchState = "closed"
        } else {
            print("Hidden")
            return
        }
//         else if notchState == "hide" {
//            DispatchQueue.main.async {
//                MusicNotch?.setContent { AnyView(OpendPlayer()) }
//            }
//            showNotch()
//        }
    }
    
    static func hideNotch() {
        MusicNotch?.hide()
    }
    @State var fetchTimer: Double = 1
    func appSetup() {
        requestAllPermissions()
        SpotifyManager.shared.startAutoUpdate(withInterval: 1)
        print(SpotifyManager.shared.trackName)
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
        callNotchHeight()
    }
}

@MainActor
@Observable
final class AppState {
    init() {
        KeyboardShortcuts.onKeyUp(for: .toggleNotch) {
            MusicNotchApp.changeNotch()
        }
    }
}
