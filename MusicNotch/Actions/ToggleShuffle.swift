//
//  ToggleShuffle.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation

func spotifyShuffle() {
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["-e", "tell application \"Spotify\" to set shuffling to not shuffling"]
    
    do {
        try task.run()
        task.waitUntilExit()
        print("Spotify Shuffle umgeschaltet")
        SpotifyManager.shared.updateInfo()
        updateShuffleIcon()
    } catch {
        print("Fehler bei der Ausführung: \(error)")
    }
}
