//
//  getPermission.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//

import Foundation

func requestAllPermissions() {
    // Erst System Events-Berechtigung anfordern
    let systemEventsTask = Process()
    systemEventsTask.launchPath = "/usr/bin/osascript"
    systemEventsTask.arguments = ["-e", "tell application \"System Events\" to name of every process"]
    
    do {
        try systemEventsTask.run()
        systemEventsTask.waitUntilExit()
        
        // Dann Spotify-Berechtigung anfordern
        let spotifyTask = Process()
        spotifyTask.launchPath = "/usr/bin/osascript"
        spotifyTask.arguments = ["-e", "tell application \"Spotify\" to name"]
        
        try spotifyTask.run()
        spotifyTask.waitUntilExit()
        
    } catch {
        print("Fehler bei der Berechtigungsanfrage: \(error)")
    }
}
