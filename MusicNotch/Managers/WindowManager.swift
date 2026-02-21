//
//  WindowManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 20.05.25.
//

import Defaults
import SwiftUI
import Luminare
import AppKit

class WindowManager {
    static var onboardingWindow: LuminareWindow?
    static var settingsWindow: LuminareWindow?
    static var aboutWindow: LuminareWindow?
    static var lockscreenWindow: MusicPlayerWindow? = nil
    
    private static func configureWindow(_ window: NSWindow?) {
        guard let window = window else { return }
        // Ensure the window is released when closed to avoid lingering snapshots
        window.isReleasedWhenClosed = true
        // Prevent participation in Mission Control / Exposé
        window.collectionBehavior.insert(.transient)
        // Avoid tabbing these utility windows
        window.tabbingMode = .disallowed
    }
    
    static func openSettings() {
        if settingsWindow == nil {
            settingsWindow = LuminareWindow{
                SettingsView()
                    .frame(width: 500, height: 600)
            }
            
            settingsWindow?.center()
            settingsWindow?.styleMask.remove(.resizable)
            configureWindow(settingsWindow)
        }
        NSApp.activate(ignoringOtherApps: true)
        
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
    
    static func closeSettings() {
        settingsWindow?.orderOut(nil)
        settingsWindow?.close()
        settingsWindow = nil
    }
    
    @objc static func openAbout() {
        if aboutWindow == nil {
            aboutWindow = LuminareWindow{
                aboutView()
                    .frame(width: 320, height: 405)
            }
            
            aboutWindow?.center()
            aboutWindow?.styleMask.remove(.resizable)
            configureWindow(aboutWindow)
        }
        NSApp.activate(ignoringOtherApps: true)
        
        aboutWindow?.makeKeyAndOrderFront(nil)
    }
    
    static func closeAbout() {
        aboutWindow?.orderOut(nil)
        aboutWindow?.close()
        aboutWindow = nil
    }
    
    static func openOnboarding() {
        let viewedOnboarding = Defaults[.viewedOnboarding]
        if viewedOnboarding == false {
            if onboardingWindow == nil {
                onboardingWindow = LuminareWindow {
                    OnboardingView()
                        .frame(width: 600, height: 350)
                }
                
                onboardingWindow?.center()
                onboardingWindow?.styleMask.remove(.resizable)
                configureWindow(onboardingWindow)
            }
            
            NSApp.activate(ignoringOtherApps: true)
            
            onboardingWindow?.makeKeyAndOrderFront(nil)
        } else { return }
    }
    
    static func closeOnboarding() {
        onboardingWindow?.orderOut(nil)
        onboardingWindow?.close()
        onboardingWindow = nil
    }
    
    static func closeAll() {
        closeSettings()
        closeAbout()
        closeOnboarding()
    }
    
    @MainActor static func showLockScreenPlayer(sendFromLock: Bool? = nil) {
        if Defaults[.lockPlayer] {
            if NotchManager.shared.notchContent == .locked || sendFromLock == true {
                if MusicManager.shared.music.isPlaying || Defaults[.alwaysShowPlayer] {
                    if lockscreenWindow == nil {
                        lockscreenWindow = MusicPlayerWindow()
                    }
                    lockscreenWindow?.orderFrontRegardless()
                }
            }
        }
    }
    
    static func hideLockScreen() {
        if Defaults[.lockPlayer] || lockscreenWindow != nil{
            lockscreenWindow?.close()
            lockscreenWindow = nil
        }
    }
    
}
