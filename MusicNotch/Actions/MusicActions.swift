//
//  MusicActions.swift
//  MusicNotch
//
//  Created by Noah Johann on 05.01.26.
//

import Foundation

struct MusicActions {
    static func playPause() {
        Task.detached(priority: .userInitiated) {
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    if let script = NSAppleScript(source: "tell application \"Music\" to playpause") {
                        try await AppleScriptHelper.run(script)
                    }
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to playpause") {
                        try await AppleScriptHelper.run(script)
                    }
                case .nowPlaying:
                    await MusicManager.shared.NPtogglePlayPause()
            }
        }
    }
    
    static func lastTrack() {
        Task.detached(priority: .userInitiated) {
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    if let script = NSAppleScript(source: "tell application \"Music\" to previous track") {
                        try await AppleScriptHelper.run(script)
                    }
                    await MusicManager.shared.updateMusic(player: .appleMusic)
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to previous track") {
                        try await AppleScriptHelper.run(script)
                    }
                    await MusicManager.shared.updateMusic(player: .spotify)
                case .nowPlaying:
                    await MusicManager.shared.NPpreviousTrack()
            }
        }
    }
    
    static func secondsBackwards() {
        Task.detached(priority: .userInitiated) {
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    break
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to set player position to (player position - 15)") {
                        try await AppleScriptHelper.run(script)
                    }
                    try await Task.sleep(for: .milliseconds(150))
                    await MusicManager.shared.updateMusic(player: .spotify)
                case .nowPlaying:
                    break
            }
        }
    }
    
    static func nextTrack() {
        Task.detached(priority: .userInitiated) {
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    if let script = NSAppleScript(source: "tell application \"Music\" to play next track") {
                        try await AppleScriptHelper.run(script)
                    }
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to next track") {
                        try await AppleScriptHelper.run(script)
                    }
                case .nowPlaying:
                    await MusicManager.shared.NPnextTrack()
            }
        }
    }
    
    static func secondsForwards() {
        Task.detached(priority: .userInitiated) {
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    break
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to set player position to (player position + 15)") {
                        try await AppleScriptHelper.run(script)
                    }
                    try await Task.sleep(for: .milliseconds(150))
                    await MusicManager.shared.updateMusic(player: .spotify)
                case .nowPlaying:
                    break
            }
        }
    }
    
    static func toggleShuffle() {
        Task.detached(priority: .userInitiated) {
           // await MainActor.run { MusicManager.shared.music.shuffle.toggle() }
            
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    if let script = NSAppleScript(source: "tell application \"Music\" to set shuffle enabled to not shuffle enabled") {
                        try await AppleScriptHelper.run(script)
                        await MusicManager.shared.updateMusic(player: .appleMusic)
                    }
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to set shuffling to not shuffling") {
                        try await AppleScriptHelper.run(script)
                        await MusicManager.shared.updateMusic(player: .spotify)
                    }
                    await MusicManager.shared.updateMusic(player: .spotify)
                case .nowPlaying:
                    break
            }
        }
    }
    
    static func toggleRepeat() {
        Task.detached(priority: .userInitiated) {
            await MainActor.run { MusicManager.shared.music.repeating.toggle() }
            
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    if let script = NSAppleScript(source: """
                        tell application "Music"
                            if song repeat is off then
                                set song repeat to all
                            else
                                set song repeat to off
                            end if
                        end tell
                        """) {
                        try await AppleScriptHelper.run(script)
                        await MusicManager.shared.updateMusic(player: .appleMusic)
                    }
                    await MusicManager.shared.updateMusic(player: .appleMusic)
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to set repeating to not repeating") {
                        try await AppleScriptHelper.run(script)
                        await MusicManager.shared.updateMusic(player: .spotify)
                    }
                    await MusicManager.shared.updateMusic(player: .spotify)
                case .nowPlaying:
                    break
            }
        }
    }
    
    static func setProgress(position: Double) {
        Task.detached(priority: .userInitiated) {
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    if let script = NSAppleScript(source: "tell application \"Music\" to set player position to \(position)") {
                        try await AppleScriptHelper.run(script)
                    }
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to set player position to \(position)") {
                        try await AppleScriptHelper.run(script)
                    }
                case .nowPlaying:
                    await MusicManager.shared.NPseek(to: position)
            }
        }
    }
    
    static func setVolume(volume: Double) {
        Task.detached(priority: .userInitiated) {
            switch await MusicManager.shared.musicPlayer {
                case .appleMusic:
                    if let script = NSAppleScript(source: "tell application \"Music\" to set sound volume to \(volume)") {
                        try await AppleScriptHelper.run(script)
                    }
                case .spotify:
                    if let script = NSAppleScript(source: "tell application \"Spotify\" to set sound volume to \(volume)") {
                        try await AppleScriptHelper.run(script)
                    }
                case .nowPlaying:
                    break
            }
        }
    }
}
