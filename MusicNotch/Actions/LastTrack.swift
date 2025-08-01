//
//  LastTrack.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation

@MainActor
func spotifyLastTrack() {
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["-e", "tell application \"Spotify\" to previous track"]
    
    do {
        try task.run()
        task.waitUntilExit()
        SpotifyManager.shared.updateInfo()
    } catch {
        print("Error while running: \(error)")
    }
    
}
