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
            Button("About MusicNotch") {
                let aboutWindow = LuminareWindow(blurRadius: 40) {
                    aboutView()
                        .frame(width: 300, height: 380)
                }
                
                aboutWindow.center()
                aboutWindow.show()
            }
            
            Button("Settings") {
                let settingsWindow = LuminareWindow(blurRadius: 40) {
                    SettingsView()
                        .frame(width: 500, height: 600)
                }
                
                settingsWindow.center()
                settingsWindow.show()
                
            } .keyboardShortcut(.init(",", modifiers: [.command]))

            Button("Quit", role: .destructive) {
                NSApp.terminate(nil)
            } .keyboardShortcut("Q", modifiers: .command)
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
            MusicNotch = DynamicNotch() {
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
