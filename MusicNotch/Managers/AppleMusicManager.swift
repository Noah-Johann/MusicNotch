//
//  AppleMusicManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 04.01.26.
//

import Defaults
import AppKit

class AppleMusicManager {
    static let shared = AppleMusicManager()
    
    public func checkIfMusicIsRunning() -> Bool {
        let workspace = NSWorkspace.shared
        
        return workspace.runningApplications.contains { app in
            app.bundleIdentifier == "com.apple.Music"
        }
    }
    
    public func setupObservers() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(appleMusicNotification),
            name: NSNotification.Name("com.apple.Music.playerInfo"),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
    }
    
    
    @objc private func appleMusicNotification(_ sender: NSNotification?) {
        guard AppleMusicManager.shared.checkIfMusicIsRunning() else { return }
        
        let musicAppKilled = sender?.userInfo?["Player State"] as? String == "Stopped"
        if musicAppKilled {
            Task {
                try? await Task.sleep(for: .milliseconds(2000))
                let running = checkIfMusicIsRunning()
                if running {
                    await MusicManager.shared.updateMusic(player: .appleMusic)
                } else {
                    if Defaults[.autoPlayer] {
                        guard await MusicManager.shared.musicPlayer == .appleMusic else { return }
                    } else {
                        guard Defaults[.musicPlayer] == .appleMusic else { return }
                    }
                    await MusicManager.shared.setDisabledPlayback()
                    return
                }
            }
        } else {
            Task { @MainActor in
                MusicManager.shared.updateMusic(player: .appleMusic)
            }
        }
    }
    
    public func checkIfPlaying() -> Bool {
        let result = AppleScriptHelper.executeAppleScript("tell application \"Music\" to set isPlaying to player state as string")
        if let stringValue = result?.stringValue, stringValue == "playing" {
            return true
        } else {
            return false
        }
    }
    
    public func collectAppleMusicInfo() -> MusicTrack? {
        guard checkIfMusicIsRunning() else { return nil }
        let script = """
            tell application "Music"
                try
                    set isPlaying to player state as string
                    set trackName to name of current track
                    set artistName to artist of current track
                    set albumName to album of current track
                    set trackDuration to duration of current track
                    set trackPosition to player position
                    try
                        set isLoved to liked of current track
                    on error
                        set isLoved to false
                    end try
                    set trackID to id of current track
                    set shuffle to shuffle enabled
                    set repeatMode to song repeat as string
                    try
                        set currentTrack to current track
                        set artworkData to data of artwork 1 of currentTrack
                    on error
                        set artworkData to nil
                    end try
                    set currentVolume to sound volume
                    return {isPlaying, trackName, artistName, albumName, trackDuration, trackPosition, isLoved, trackID, shuffle, repeatMode, artworkData, currentVolume}
                on error
                    return {}
                end try
            end tell
        """
        
        let result = AppleScriptHelper.executeAppleScript(script)
        guard
            let descriptor = result,
            descriptor.numberOfItems >= 12
        else {
            print("Invalid AppleScript result")
            return nil
        }
        
        let returnTrack = MusicTrack (
            trackName: descriptor.atIndex(2)?.stringValue ?? "",
            artistName: descriptor.atIndex(3)?.stringValue ?? "",
            albumName: descriptor.atIndex(4)?.stringValue ?? "",
            trackDuration: descriptor.atIndex(5)?.doubleValue ?? 1,
            trackPosition: descriptor.atIndex(6)?.doubleValue ?? 0,
            isPlaying: descriptor.atIndex(1)?.stringValue == "playing",
            isLoved: descriptor.atIndex(7)?.booleanValue ?? false,
            shuffle: descriptor.atIndex(9)?.booleanValue ?? false,
            repeating: {
                switch descriptor.atIndex(10)?.stringValue {
                case "all":
                    return .all
                case "one":
                    return .one
                default:
                    return .off
                }
            }(),
            volume: descriptor.atIndex(12) != nil ? CGFloat(descriptor.atIndex(12)!.doubleValue) : nil,
            type: .music
        )
        
        if let data = descriptor.atIndex(11)?.data {
            Task { @MainActor in
                MusicManager.shared.albumArt = NSImage(data: data)
                NSImage(data: data)?.averageColor { color in
                    MusicManager.shared.aveColor = color
                }
            }
        } else {
            Task { @MainActor in
                MusicManager.shared.albumArt = NSImage(named: "no_playback")
            }
        }
                
        return returnTrack
        
    }
}
