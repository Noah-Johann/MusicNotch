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
    static let shared = WindowManager()
    
    private var settingsController: NSWindowController?
    private var aboutController: NSWindowController?
    private var onboardingController: NSWindowController?
    
    var settingsWindow: NSWindow? { settingsController?.window }
    var aboutWindow: NSWindow? { aboutController?.window }
    var onboardingWindow: NSWindow? { onboardingController?.window }
 
    var lockscreenWindow: MusicPlayerWindow? = nil
        
    private func configureWindow(_ window: NSWindow?) {
        guard let window = window else { return }
        // Ensure the window is released when closed to avoid lingering snapshots
        window.isReleasedWhenClosed = true
        // Prevent participation in Mission Control / Exposé
     //   window.collectionBehavior.insert(.transient)
        // Avoid tabbing these utility windows
      //  window.tabbingMode = .disallowed
    }
    
    func openSettings() {
        if settingsController == nil {
            let window = LuminareWindow{
                SettingsView()
                    .frame(width: 625, height: 575)
            }
            
            settingsController = NSWindowController(window: window)
        }
        settingsWindow?.isReleasedWhenClosed = true
        settingsController?.showWindow(self)
        settingsWindow?.orderFrontRegardless()
        
        NSApp.activate()
    }
    
    func closeSettings() {
        if let settingsController {
            settingsController.close()
            self.settingsController = nil
        }
    }
    
    func openAbout() {
        if aboutController == nil {
            let window = LuminareWindow{
                aboutView()
                    .frame(width: 320, height: 405)
            }
            
            aboutController = NSWindowController(window: window)
 
        }
        
        aboutWindow?.isReleasedWhenClosed = true
        aboutController?.showWindow(self)
        aboutWindow?.orderFrontRegardless()
        
        NSApp.activate()
    }
    
    func closeAbout() {
        if let aboutController {
            aboutController.close()
            self.aboutController = nil
        }
    }
    
    func openOnboarding() {
        if onboardingController == nil {
            let window = LuminareWindow {
                OnboardingView()
                    .frame(width: 600, height: 350)
            }
            
            onboardingController = NSWindowController(window: window)
        }
        
        onboardingWindow?.isReleasedWhenClosed = true
        onboardingController?.showWindow(self)
        onboardingWindow?.orderFrontRegardless()
        
        NSApp.activate()
    }
    
    func closeOnboarding() {
        if let onboardingController {
            onboardingController.close()
            self.onboardingController = nil
        }
    }
    
    func closeAll() {
        closeSettings()
        closeAbout()
        closeOnboarding()
    }
    
    @MainActor func showLockScreenPlayer(sendFromLock: Bool? = nil) {
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
    
    func hideLockScreen() {
        if Defaults[.lockPlayer] || lockscreenWindow != nil{
            lockscreenWindow?.close()
            lockscreenWindow = nil
        }
    }
    
}
