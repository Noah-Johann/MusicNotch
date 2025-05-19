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
                
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
        
        KeyboardShortcuts.onKeyDown(for: .toggleNotch) {
            NotchManager.shared.changeNotch()
        }
        
        timer = 0
    }
    
    var body: some Scene {
        MenuBarExtra("MusicNotch", image: "notch.square", isInserted: Binding(get: {
            showMenuBarItem
        }, set: { _ in })) {
            MenuBarExtraView(appDelegate: appDelegate)
        }
    }

    func appSetup() {
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
        SpotifyManager.shared.updateInfo()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var onboarding: LuminareWindow?
    var settingsWindow: LuminareWindow?
    var aboutWindow: LuminareWindow?

    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegateHolder.shared = self
        print("finish")
        self.onboarding = LuminareWindow {
            OnboardingView()
                .frame(width: 600, height: 350)
        }
        self.onboarding?.styleMask.remove(.resizable)
        
        self.settingsWindow = LuminareWindow {
            SettingsView()
                .frame(width: 500, height: 600)
        }
        self.settingsWindow?.styleMask.remove(.resizable)
        
        self.aboutWindow = LuminareWindow {
            aboutView()
                .frame(width: 300, height: 380)
        }
        self.aboutWindow?.styleMask.remove(.resizable)
        
        showOnboarding()
    }
    
    func showOnboarding() {
        let viewedOnboarding = Defaults[.viewedOnboarding]
        
        if viewedOnboarding == false {
            self.onboarding?.center()
            self.onboarding?.level = .floating
            self.onboarding?.makeKeyAndOrderFront(nil)
            
        } else {
            print("Already saw onboarding")
            return
        }
    }
    
    func hideOnboarding () {
        onboarding?.close()
        
    }
    
    func showAboutWindow() {
        NSApp.activate(ignoringOtherApps: true)
        self.aboutWindow?.center()
        self.aboutWindow?.level = .floating
        self.aboutWindow?.makeKeyAndOrderFront(nil)
    }
    
    func showSettingsWindow() {

        NSApp.activate(ignoringOtherApps: true)
        self.settingsWindow?.center()
        self.settingsWindow?.level = .floating
        self.settingsWindow?.makeKeyAndOrderFront(nil)
    }

}

class AppDelegateHolder {
    static var shared: AppDelegate?
}
