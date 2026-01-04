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
        if checkIfSpotifyIsRunning() {
            isSpotifyRunning = true
        }
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
                return {false, "", "", "", 1, 0, false, 0, false, ""}
            end try
        end tell
        """
        
        let result = AppleScriptHelper.executeAppleScript(script)
        if let resultString = result as? String {
            let cleanedResult = resultString
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "") }
            
            var finalResult = cleanedResult
            if let last = finalResult.last, last.isEmpty {
                finalResult.removeLast()
            }
                        
            if finalResult.count >= 10 {
                let returnTrack = MusicTrack (
                    trackName: finalResult[1],
                    artistName: finalResult[2],
                    albumName: finalResult[3],
                    trackDuration: Int(Double(finalResult[4]) ?? 0),
                    trackPosition: Int(Double(finalResult[5]) ?? 0),
                    isPlaying: finalResult[0] == "playing",
                    isLoved: finalResult[6] == "true",
                    shuffle: finalResult[8] == "true",
                )
                                
                if oldTrackName != returnTrack.trackName {
                    oldTrackName = returnTrack.trackName
                    Task { @MainActor in
                        fetchAlbumArt(albumUrl: finalResult[9])
                    }
                }
                
                return returnTrack
                
            } else {
                print("Error on getting information or spotify not running")
                return nil
            }
        } else {
            print("Fehler: Didn't get any result")
            return nil
        }
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
