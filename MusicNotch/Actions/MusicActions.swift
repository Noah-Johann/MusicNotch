//
//  MusicActions.swift
//  MusicNotch
//
//  Created by Noah Johann on 05.01.26.
//

import Foundation
import Defaults
import MediaRemoteAdapter

struct MusicActions {
    let mediaController = MediaController()
    
    static func playPause() {
        Task {
            switch await MusicManager.shared.musicPlayer {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to playpause")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to playpause")
            case .nowPlaying:
                await MusicManager.shared.NPtogglePlayPause()
            }
        }
    }
    
    static func lastTrack() {
        Task {
            switch await MusicManager.shared.musicPlayer {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to previous track")
                await MusicManager.shared.updateMusic(player: .appleMusic)
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to previous track")
                await MusicManager.shared.updateMusic(player: .spotify)
            case .nowPlaying:
                await MusicManager.shared.NPpreviousTrack()
            }
        }
    }
    
    static func secondsBackwards() {
        Task {
            switch await MusicManager.shared.musicPlayer {
            case .appleMusic:
                break
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to set player position to (player position - 15)")
                try await Task.sleep(for: .milliseconds(150))
                await MusicManager.shared.updateMusic(player: .spotify)
            case .nowPlaying:
                break
            }
        }
    }
    
    static func nextTrack() {
        Task {
            switch await MusicManager.shared.musicPlayer {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to play next track")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to next track")
            case .nowPlaying:
                await MusicManager.shared.NPnextTrack()
            }
        }
    }
    
    static func secondsForwards() {
        Task {
            switch await MusicManager.shared.musicPlayer {
            case .appleMusic:
                break
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to set player position to (player position + 15)")
                try await Task.sleep(for: .milliseconds(150))
                await MusicManager.shared.updateMusic(player: .spotify)
            case .nowPlaying:
                break
            }
        }
    }

    static func toggleShuffle() {
        Task {
            switch await MusicManager.shared.musicPlayer {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to set shuffle enabled to not shuffle enabled")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to set shuffling to not shuffling")
                await MusicManager.shared.updateMusic(player: .spotify)
            case .nowPlaying:
                break
            }
        }
    }
    
    static func setProgress(position: Double) {
        Task {
            switch await MusicManager.shared.musicPlayer {
            case .appleMusic:
                try await AppleScriptHelper.run("tell application \"Music\" to set player position to \(position)")
            case .spotify:
                try await AppleScriptHelper.run("tell application \"Spotify\" to set player position to \(position)")
            case .nowPlaying:
                await MusicManager.shared.NPseek(to: position)
            }
        }
    }

    static func setVolume(volume: Double) {
        Task {
            switch await MusicManager.shared.musicPlayer {
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
