//
//  AppleMusicManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 04.01.26.
//

import Foundation
import AppKit

@MainActor
class AppleMusicManager {
    static let shared = AppleMusicManager()
    
    public func checkIfMusicIsRunning() -> Bool {
        let workspace = NSWorkspace.shared
        
        return workspace.runningApplications.contains { app in
            app.bundleIdentifier == "com.apple.Music"
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
                    try
                        set currentTrack to current track
                        set artworkData to data of artwork 1 of currentTrack
                    on error
                        set artworkData to nil
                    end try
                    set currentVolume to sound volume
                    return {isPlaying, trackName, artistName, albumName, trackDuration, trackPosition, isLoved, trackID, shuffle, artworkData, currentVolume}
                on error
                    return {}
                end try
            end tell
        """
        
        let result = AppleScriptHelper.executeAppleScript(script)
        guard
            let descriptor = result,
            descriptor.numberOfItems >= 11
        else {
            print("Invalid AppleScript result")
            return nil
        }
        
        let returnTrack = MusicTrack (
            trackName: descriptor.atIndex(2)?.stringValue ?? "",
            artistName: descriptor.atIndex(3)?.stringValue ?? "",
            albumName: descriptor.atIndex(4)?.stringValue ?? "",
            trackDuration: Int(descriptor.atIndex(5)?.doubleValue ?? 0),
            trackPosition: Int(descriptor.atIndex(6)?.doubleValue ?? 0),
            isPlaying: descriptor.atIndex(1)?.stringValue == "playing",
            isLoved: descriptor.atIndex(7)?.booleanValue ?? false,
            shuffle: descriptor.atIndex(9)?.booleanValue ?? false,
            volume: descriptor.atIndex(11) != nil ? CGFloat(descriptor.atIndex(11)!.doubleValue) : nil
        )
        
        if let data = descriptor.atIndex(10)?.data {
            MusicManager.shared.albumArt = NSImage(data: data)
            MusicManager.shared.getAverageColor()
        } else {
            MusicManager.shared.albumArt = NSImage(named: "no_playback")
        }
                
        return returnTrack
        
    }
}
