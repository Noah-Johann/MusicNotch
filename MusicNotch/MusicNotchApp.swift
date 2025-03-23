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
        appSetup()
        showDynamicNotch()
    }

    var body: some Scene {
        WindowGroup {
            OpendPlayer()
        }
    }

    func showDynamicNotch() {
        var opendNotch = DynamicNotch(style: .notch) {
            closedPlayer()
        }
        opendNotch.show()
        opendNotch.setContent { closedPlayer() }
        
        
        
    }
    
    func appSetup() {
        requestAllPermissions()
        SpotifyManager.shared.startAutoUpdate(withInterval: 1)
        print(SpotifyManager.shared.trackName)
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
    }
}


