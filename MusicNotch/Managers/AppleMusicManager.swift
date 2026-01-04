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
    
    public func collectAppleMusicInfo() -> MusicTrack? {
        let script = """
                tell application "Music"
                    set results to {}
                    
                    try
                        set isPlaying to player state as String
                        set end of results to isPlaying
                    on error
                        set end of results to "stopped"
                    end try
                    
                    try
                        set trackName to name of current track
                        set end of results to trackName
                    on error
                        set end of results to ""
                    end try
                    
                    try
                        set artistName to artist of current track
                        set end of results to artistName
                    on error
                        set end of results to ""
                    end try
                    
                    try
                        set albumName to album of current track
                        set end of results to albumName
                    on error
                        set end of results to ""
                    end try
                    
                    try
                        set trackDuration to duration of current track
                        set end of results to trackDuration
                    on error
                        set end of results to 0
                    end try
                    
                    try
                        set trackPosition to player position
                        set end of results to trackPosition
                    on error
                        set end of results to 0
                    end try
                    
                    try
                        set isLoved to loved of current track
                        set end of results to isLoved
                    on error
                        set end of results to false
                    end try
                    
                    try
                        set trackId to id of current track
                        set end of results to trackId
                    on error
                        set end of results to ""
                    end try
        
                    try
                        set shuffle to shuffling
                        set end of results to shuffle
                    on error
                        set end of results to false
                    end try
                    
                    return results
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
            
            if finalResult.count >= 9 {
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
                
                let artworkScript = """
                tell application "Music"
                    try
                        if player state is playing then
                            if (count of artworks of current track) > 0 then
                                return data of artwork 1 of current track
                            end if
                        end if
                    end try
                    return missing value
                end tell
                """

                if let artworkResult = AppleScriptHelper.executeAppleScript(artworkScript) as? Data {
                    MusicManager.shared.albumArt = NSImage(data: artworkResult)
                    MusicManager.shared.getAverageColor()
                } else {
                    MusicManager.shared.albumArt = NSImage(named: "no_playback")
                }
                
                return returnTrack
                
            } else {
                print("Error on getting information or music not running")
                return nil
            }
        } else {
            print("Error: Didn't get any result")
            return nil
        }
    }
}
