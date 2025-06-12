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
    
    static func openSettings() {
        if settingsWindow == nil {
            settingsWindow = LuminareWindow{
                SettingsView()
                    .frame(width: 500, height: 600)
            }
            
            settingsWindow?.center()
            settingsWindow?.level = .floating
            settingsWindow?.styleMask.remove(.resizable)
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        
        NSApp.setActivationPolicy(.regular)
    }
    
    static func closeSettings() {
        NSApp.setActivationPolicy(.accessory)

        settingsWindow?.close()
        settingsWindow = nil
    }
    
    @objc static func openAbout() {
        if aboutWindow == nil {
            aboutWindow = LuminareWindow{
                aboutView()
                    .frame(width: 300, height: 380)
            }
            
            aboutWindow?.center()
            aboutWindow?.level = .floating
            aboutWindow?.styleMask.remove(.resizable)
            
        }
        
        aboutWindow?.makeKeyAndOrderFront(nil)
        
        NSApp.setActivationPolicy(.regular)

    }
    
    static func closeAbout() {
        NSApp.setActivationPolicy(.accessory)

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
                onboardingWindow?.level = .floating
                onboardingWindow?.styleMask.remove(.resizable)
            }
            
            onboardingWindow?.makeKeyAndOrderFront(nil)
            
            NSApp.setActivationPolicy(.regular)
        } else { return }
    }
    
    static func closeOnboarding() {
        NSApp.setActivationPolicy(.accessory)
        
        onboardingWindow?.close()
        onboardingWindow = nil
    }
    
    static func closeAll() {
        closeSettings()
        closeAbout()
        closeOnboarding()
    }
    
}

class AboutMenuHandler: NSObject {
    @objc func showAboutMenu() {
        WindowManager.openAbout()
    }
}
