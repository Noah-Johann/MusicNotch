//
//  PlayPause.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation

func spotifyPlayPause() {
    let task = Process()
    task.launchPath = "/usr/bin/osascript"
    task.arguments = ["-e", "tell application \"Spotify\" to playpause"]
    
    do {
        try task.run()
    } catch {
        print("Error while running: \(error)")
    }
    
}

