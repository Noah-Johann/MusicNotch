//
//  NextTrack.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation
import Defaults

func nextTrack() {
    Task {
        switch Defaults[.musicPlayer] {
        case .appleMusic:
            try await AppleScriptHelper.run("tell application \"Music\" to play next track")
        case .spotify:
            try await AppleScriptHelper.run("tell application \"Spotify\" to next track")
        case .nowPlaying:
            break
        }
    }
}
