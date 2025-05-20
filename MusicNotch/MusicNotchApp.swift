//
//  MusicNotchApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import SwiftUI
import KeyboardShortcuts
import Defaults
import Luminare

var notchState: String = "hide"

@main
struct MusicNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var showMenuBarIcon: Bool = true
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @Default(.showMenuBarItem) private var showMenuBarItem
    
    init() {
        appSetup()
                
//        DispatchQueue.main.async {
//            NSApp.setActivationPolicy(.accessory)
//        }
        
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

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let aboutMenuHandler = AboutMenuHandler()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if Defaults[.viewedOnboarding] == false {
            WindowManager.openOnboarding()
        } else {
            WindowManager.openSettings()
        }
        
        if let mainMenu = NSApp.mainMenu,
           let appMenu = mainMenu.items.first?.submenu,
           let aboutItem = appMenu.items.first(where: { $0.action == #selector(NSApplication.orderFrontStandardAboutPanel(_:)) }) {
            aboutItem.target = aboutMenuHandler
            aboutItem.action = #selector(AboutMenuHandler.showAboutMenu)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        WindowManager.closeAll()
        return false
    }
    
    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        WindowManager.openSettings()
        return true
    }
}

