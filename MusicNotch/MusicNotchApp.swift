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
            NotchManager.shared.toggleNotch()
        }
        KeyboardShortcuts.onKeyDown(for: .toggleMusicGlance) {
            NotchManager.shared.toggleMusicGlance()
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
        MenuBarExtra("MusicNotch", image: "notch.square", isInserted: Binding(get: {
            showMenuBarItem
        }, set: { _ in })) {
            MenuBarExtraView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotchManager.shared.createNotch()
        
        if Defaults[.viewedOnboarding] == false {
            WindowManager.openOnboarding()
        } else {
            if Defaults[.silentLaunch] == false {
                WindowManager.openSettings()
            }
            MusicManager.shared.updateMusic()
        }
        
        NSApp.setActivationPolicy(.accessory)
                
        CGDisplayRegisterReconfigurationCallback(displayCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        WindowManager.closeAll()
        return false
    }
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        CGDisplayRemoveReconfigurationCallback(displayCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
}

private func displayCallback(
    _ display: CGDirectDisplayID,
    _ flags: CGDisplayChangeSummaryFlags,
    _ userInfo: UnsafeMutableRawPointer?
) {
    guard userInfo != nil else { return }

    if flags.contains(.addFlag) || flags.contains(.removeFlag) {
        print("Display connected or disconnected")
            Task { @MainActor in
                await NotchManager.shared.setNotchState(.hidden, changeDisplay: true)
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            Task { @MainActor in
                await NotchManager.shared.setNotchState(.compact, changeDisplay: true)
            }
        }
    }
}
