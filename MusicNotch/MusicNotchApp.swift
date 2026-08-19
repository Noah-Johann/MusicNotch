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
import Sparkle


@main
struct MusicNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var showMenuBarIcon: Bool = true
    
    
    @Default(.showMenuBarItem) private var showMenuBarItem
    
    init() {
        KeyboardShortcuts.onKeyDown(for: .toggleNotch) {
            Task {
                await NotchManager.shared.toggleNotch()
            }
        }
        KeyboardShortcuts.onKeyDown(for: .toggleMusicGlance) {
            Task {
                await NotchManager.shared.toggleMusicGlance()
            }
        }
        
        let handlers: [(KeyboardShortcuts.Name, () -> Void)] = [
            (.nextTrack, MusicActions.nextTrack),
            (.previousTrack, MusicActions.lastTrack),
            (.toggleShuffle, MusicActions.toggleShuffle),
            (.playPause, MusicActions.playPause),
        ]
        handlers.forEach { name, action in
            KeyboardShortcuts.onKeyDown(for: name, action: action)
        }
    }
    
    var body: some Scene {
        MenuBarExtra("MusicNotch", image: "notch.square", isInserted: $showMenuBarItem) {
            MenuBarExtraView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotchManager.shared.createNotch()
        
        if Defaults[.viewedOnboarding] == false {
            WindowManager.shared.openOnboarding()
        } else {
            if Defaults[.silentLaunch] == false {
                WindowManager.shared.openSettings()
            }
            MusicManager.shared.refreshMusic()
        }
        
        NSApp.setActivationPolicy(.accessory)
                
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return false
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) { }
}
