//
//  MusicNotchApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import SwiftUI
import DynamicNotchKit

@main
struct MusicNotchApp: App {
    init() {
        showDynamicNotch()
    }

    var body: some Scene {
        WindowGroup {
            OpendPlayer()
        }
    }

    func showDynamicNotch() {
        let opendNotch = DynamicNotch {
            OpendPlayer()
        }
        requestAllPermissions()
        SpotifyManager.shared.startAutoUpdate(withInterval: 1)
        print(SpotifyManager.shared.trackName)
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
        opendNotch.show(on: NSScreen.screens[1])
        
        
    }
}
