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
    static var opendNotch: DynamicNotch<AnyView>? = nil // Make it a static property

    init() {
        appSetup()
        timer = 0
        // Start the delay mechanism here to ensure proper timing
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            MusicNotchApp.showNotch()
        }

        for i in 0...30 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1) {
                MusicNotchApp.showDynamicNotch()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            OpendPlayer()
        }
    }

    static func showDynamicNotch() {
        if opendNotch == nil {
            opendNotch = DynamicNotch(style: .notch) {
                AnyView(OpendPlayer()) // Ensure uniform return type
            }
        }
        
        print(timer)
        
        if timer == 20 {
            print("Change content")
            
            DispatchQueue.main.async {
                opendNotch?.setContent { AnyView(closedPlayer()) }
            }
        }
        if timer == 25 {
            DispatchQueue.main.async {
                opendNotch?.setContent { AnyView(OpendPlayer()) }
            }
        }
    }
    
    static func showNotch() {
        MusicNotchApp.opendNotch?.show() // Use the static opendNotch property
        print("shownotch")
    }
    
    func appSetup() {
        requestAllPermissions()
        SpotifyManager.shared.startAutoUpdate(withInterval: 1)
        print(SpotifyManager.shared.trackName)
        getAudioOutputDevice()
        registerForAudioDeviceChanges()
    }
}
