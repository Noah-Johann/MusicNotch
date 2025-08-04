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


@main
struct MusicNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var showMenuBarIcon: Bool = true
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @Default(.showMenuBarItem) private var showMenuBarItem
    
    init() {
        KeyboardShortcuts.onKeyDown(for: .toggleNotch) {
            SpotifyManager.shared.timer = 3
            NotchManager.shared.changeNotch()
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
    let aboutMenuHandler = AboutMenuHandler()
    
    private let batteryManager = BatteryManager.shared

    
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
                
        CGDisplayRegisterReconfigurationCallback(displayCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        WindowManager.closeAll()
        return false
    }
    
    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        WindowManager.openSettings()
        return true
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
        DispatchQueue.main.async {
            NotchManager.shared.setNotchContent(.hidden, true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            NotchManager.shared.setNotchContent(.closed, true)
        })
    }
}
