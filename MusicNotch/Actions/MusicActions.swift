//
//  MusicActions.swift
//  MusicNotch
//
//  Created by Noah Johann on 05.01.26.
//

import Foundation
import Defaults

struct MusicActions {
    static func playPause() {
        Task {
            switch Defaults[.musicPlayer] {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to playpause")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to playpause")
            case .nowPlaying:
                break
            }
        }
    }
    
    static func lastTrack() {
        Task {
            switch Defaults[.musicPlayer] {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to previous track")
                await MusicManager.shared.updateMusic()
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to previous track")
                await MusicManager.shared.updateMusic()
            case .nowPlaying:
                break
            }
        }
    }
    
    static func nextTrack() {
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

    static func toggleShuffle() {
        Task {
            switch Defaults[.musicPlayer] {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to set shuffle enabled to not shuffle enabled")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to set shuffling to not shuffling")
                await MusicManager.shared.updateMusic()
            case .nowPlaying:
                break
            }
        }
    }
    
    static func setProgress(position: Double) {
        Task {
            switch Defaults[.musicPlayer] {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to set player position to \(position)")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to set player position to \(position)")
            case .nowPlaying:
                break
            }
        }
    }

    static func setVolume(volume: Double) {
        Task {
            switch Defaults[.musicPlayer] {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to set sound volume to \(volume)")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to set sound volume to \(volume)")
            case .nowPlaying:
                break
            }
        }
    }
}
