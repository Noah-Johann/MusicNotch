//
//  WindowManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 20.05.25.
//

import Defaults
import SwiftUI
import Luminare
import JochexUI
import AppKit

@Observable
class SettingsViewManager {
    static let shared = SettingsViewManager()
    
    var selection: SettingsTab = .general
    var isExpanded: Bool = false
}


class WindowManager {
    static let shared = WindowManager()
    
    private var settingsController: NSWindowController?
    private var aboutController: NSWindowController?
    private var onboardingController: NSWindowController?
    
    var settingsWindow: NSWindow? { settingsController?.window }
    var aboutWindow: NSWindow? { aboutController?.window }
    var onboardingWindow: NSWindow? { onboardingController?.window }
 
    var lockscreenWindow: MusicPlayerWindow? = nil
    
    func openSettings() {
        if settingsController == nil {
            let window = JochexWindow(width: 500, height: 600) {
                SettingsView()
            } tabBar: {
                SettingsTabBarView()
            }
            
            settingsController = NSWindowController(window: window)
        }
        settingsController?.showWindow(self)
        settingsWindow?.orderFrontRegardless()
        
        NSApp.activate()
    }
    
    func openAbout() {
        if aboutController == nil {
            let window = JochexPlainWindow(windowWidth: 315, windowHeight: 380) {
                aboutView()
            }
            
            aboutController = NSWindowController(window: window)
 
        }
        
        aboutController?.showWindow(self)
        aboutWindow?.orderFrontRegardless()
        
        NSApp.activate()
    }
    
    func openOnboarding() {
        if onboardingController == nil {
            let window = JochexPlainWindow(windowWidth: 600, windowHeight: 350) {
                OnboardingView()
            }
            
            onboardingController = NSWindowController(window: window)
        }
        
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
