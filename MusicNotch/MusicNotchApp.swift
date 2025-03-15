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
        let dynamicNotch = DynamicNotch {
            OpendPlayer()
        }
        dynamicNotch.show(on: NSScreen.screens[1], for: 20)
        requestAllPermissions()
        SpotifyManager.shared.startAutoUpdate(withInterval: 1.0)
        print(SpotifyManager.shared.trackName)
        print(getModelIdentifier())
        
        
    }
}
