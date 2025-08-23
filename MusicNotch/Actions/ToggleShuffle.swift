//
//  ToggleShuffle.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation

func spotifyShuffle() {
    Task {
        try await AppleScriptHelper.run("tell application \"Spotify\" to set shuffling to not shuffling")
    }
}
