//
//  MusicNotchApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import SwiftUI
import DynamicNotchKit
import KeyboardShortcuts
import LaunchAtLogin
import Luminare
import Defaults

var notchState: String = "hide"

@main
struct MusicNotchApp: App {

    static var MusicNotch: DynamicNotch<AnyView>? = nil
    @State private var showMenuBarIcon: Bool = true
    
    
    init() {
        appSetup()
        
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
        showOnboarding()
        
        KeyboardShortcuts.onKeyDown(for: .toggleNotch) {
            MusicNotchApp.changeNotch()
        }
        
        timer = 0
    }
    
    var body: some Scene {
        
        MenuBarExtra("MusicNotch", image: "notch.square", isInserted: $showMenuBarIcon) {
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
                Text("Version \(Bundle.main.appVersion!) (\(Bundle.main.appBuild!))")
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
    
    static func showOnNotchScreen() {
        DispatchQueue.main.async {
            MusicNotch?.setContent { AnyView(Player(notchState: "closed")) }
        }
        guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
            print("No notch screen found")
            MusicNotch?.show(on: NSScreen.screens.first!)
            return
        }
        
    
        MusicNotch?.show(on: notchScreen)

    }

    static func showNotch() {
        
        if MusicNotch == nil {
            MusicNotch = DynamicNotch(hoverBehavior: .increaseShadow, style: .notch) {
                AnyView(Player(notchState: "closed")) }
            notchState = "closed"
        }
        
        showOnNotchScreen()
    }
    
    static func changeNotch() {
        if notchState == "closed" {
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(Player(notchState: "open")) }
            }
            SpotifyManager.shared.updateInfo()
            notchState = "open"
        } else if notchState == "open" {
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(Player(notchState: "closed")) }
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
    
    static func updateNotch() {
        if notchState == "closed" {
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(Player(notchState: "open")) }
            }
            SpotifyManager.shared.updateInfo()
            notchState = "open"
        } else if notchState == "open" {
            DispatchQueue.main.async {
                MusicNotch?.setContent { AnyView(Player(notchState: "closed")) }
            }
            notchState = "closed"
        } else {
            print("Hidden")
            return
        }
    }
    
    static func hideNotch() {
        MusicNotch?.hide()
        notchState = "hide"
    }
    
    func appSetup() {
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
        callNotchHeight()
        SpotifyManager.shared.updateInfo()
    }
}
