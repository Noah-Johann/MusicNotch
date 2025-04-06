//
//  NextTrack.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation

func spotifyNextTrack() {
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["-e", "tell application \"Spotify\" to next track"]
    
    do {
        try task.run()
        task.waitUntilExit()
        SpotifyManager.shared.updateInfo()
        updatePlayIcon()
    } catch {
        print("Fehler bei der Ausführung: \(error)")
    }
    
}
