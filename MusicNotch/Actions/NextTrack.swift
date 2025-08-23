//
//  NextTrack.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation

func spotifyNextTrack() {
    Task {
        try await AppleScriptHelper.run("tell application \"Spotify\" to next track")
    }
}
