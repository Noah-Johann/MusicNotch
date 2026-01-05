//
//  SpotifyManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//


import Foundation
import AppKit
import Defaults
import SwiftUI

@MainActor
class SpotifyManager {
    static let shared = SpotifyManager()
                    
    public var isSpotifyRunning: Bool = false
    
    public var oldTrackName: String = ""
    
    private init() {
        isSpotifyRunning = checkIfSpotifyIsRunning()
    }

    
    public func checkIfSpotifyIsRunning() -> Bool {
        let workspace = NSWorkspace.shared
        
        return workspace.runningApplications.contains { app in
            app.bundleIdentifier == "com.spotify.client"
        }
    }
      
    public func collectSpotifyInfo() -> MusicTrack? {
        guard checkIfSpotifyIsRunning() else { return nil }
        
        let script = """
        tell application "Spotify"
            try
                set isPlaying to player state as string
                set trackName to name of current track
                set artistName to artist of current track
                set albumName to album of current track
                set trackDuration to duration of current track / 1000
                set trackPosition to player position
                try
                    set isLoved to loved of current track
                on error
                    set isLoved to false
                end try
                set trackID to id of current track
                set shuffle to shuffling
                try
                    set albumArt to artwork url of current track
                on error
                    set albumArt to ""
                end try
                return {isPlaying, trackName, artistName, albumName, trackDuration, trackPosition, isLoved, trackID, shuffle, albumArt}
            on error
                return {}
            end try
        end tell
        """
        
        let result = AppleScriptHelper.executeAppleScript(script)
        guard
            let descriptor = result,
            descriptor.numberOfItems >= 10
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
        )
        
        if oldTrackName != returnTrack.trackName {
            oldTrackName = returnTrack.trackName
            Task { @MainActor in
                fetchAlbumArt(albumUrl: descriptor.atIndex(10)?.stringValue ?? "")
            }
        }
        return returnTrack
    }
    
    @MainActor
    private func fetchAlbumArt(albumUrl: String) {
        print("fetchAlbumArt")
         guard let url = URL(string: albumUrl) else { return }
        print("haveURL")
         URLSession.shared.dataTask(with: url) { data, _, _ in
             guard let data = data, let image = NSImage(data: data) else {
                 Task { @MainActor in
                     MusicManager.shared.albumArt = NSImage(named: "no_playback")
                 }
                 return
             }
             Task { @MainActor in
                 MusicManager.shared.albumArt = image
                 MusicManager.shared.getAverageColor()
             }
         }.resume()
     }
}
