//
//  ToggleShuffle.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation
import Defaults

func spotifyShuffle() {
    Task {
        switch Defaults[.musicPlayer] {
        case .appleMusic:
            try await AppleScriptHelper.run("tell application \"Music\" to set shuffle enabled to not shuffle enabled")
            await MusicManager.shared.updateMusic()
        case .spotify:
            try await AppleScriptHelper.run("tell application \"Spotify\" to set shuffling to not shuffling")
            await MusicManager.shared.updateMusic()
        case .nowPlaying:
            break
        }
    }
}
