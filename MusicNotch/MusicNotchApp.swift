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

var notchState: String = "closed"

@main
struct MusicNotchApp: App {
    static var MusicNotch: DynamicNotch<AnyView>? = nil // Make it a static property
    @State private var appState = AppState()
    @State private var showMenuBarIcon: Bool = true
    
    init() {
        appSetup()
        timer = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("shownotch")
            MusicNotchApp.showNotch()

        }
    }
    
    var body: some Scene {
        
        MenuBarExtra("MusicNotch", image: "notchsquare", isInserted: $showMenuBarIcon) {
            Button("About MusicNotch") {
                NSApp.orderFrontStandardAboutPanel()
            }
            
            Button("Settings") {
                let settingsWindow = LuminareWindow(blurRadius: 40) {
                    SettingsView()
                        .frame(width: 500, height: 600)
                }

                // Get the screen's frame
                if let screen = NSScreen.main {
                    let screenFrame = screen.frame
                    let windowWidth: CGFloat = 500 // Width of the settings window
                    let windowHeight: CGFloat = 600 // Height of the settings window
                    
                    // Calculate the origin to center the window
                    let origin = CGPoint(
                        x: (screenFrame.width - windowWidth) / 2,
                        y: (screenFrame.height - windowHeight) / 2
                    )

                    // Set the frame to the calculated origin
                    settingsWindow.setFrame(CGRect(origin: origin, size: CGSize(width: windowWidth, height: windowHeight)), display: true)
                }

                settingsWindow.show()
            }

            Button("Quit", role: .destructive) {
                NSApp.terminate(nil)
            }
        }
        
    }
    
    static func showOnNotchScreen() {
        DispatchQueue.main.async {
            MusicNotch?.setContent { AnyView(closedPlayer()) }
        }
        guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
            print("No notch screen found")
            MusicNotch?.show(on: NSScreen.screens.first!)
            return
        }
        
    
        MusicNotch?.show(on: notchScreen)
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
            SpotifyManager.shared.updateInfo()
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
        notchState = "hide"
    }
    
    func appSetup() {
        requestAllPermissions()
        print(SpotifyManager.shared.trackName)
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
        callNotchHeight()
        SpotifyManager.shared.updateInfo()
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

