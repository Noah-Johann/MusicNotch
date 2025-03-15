//
//  LastTrack.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation

func spotifyLastTrack() {
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["-e", "tell application \"Spotify\" to previous track"]
    
    do {
        try task.run()
        task.waitUntilExit()
        print("Spotify Play/Pause ausgeführt")
        SpotifyManager.shared.updateInfo()
        updatePlayIcon()
    } catch {
        print("Fehler bei der Ausführung: \(error)")
    }
    
}
