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
class SpotifyManager: ObservableObject {
    static let shared = SpotifyManager()
                    
    @Published var isSpotifyRunning: Bool = false
    
    private var oldTrackName: String = ""
    
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
                    set results to {}
                    
                    try
                        set isPlaying to player state as string
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
                        set trackDuration to duration of current track / 1000
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
                    
                    try
                        set albumArt to artwork url of current track
                        set end of results to albumArt
                    on error
                        set end of results to ""
                    end try
                    
                    return results
                end tell
        """
        
        let result = executeAppleScript(script)
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
    
    private func executeAppleScript(_ script: String) -> Any? {
        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-ss", "-e", script]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            }
        } catch {
            print("AppleScript-Error: \(error)")
        }
        
        return nil
    }
    
    private func fetchAlbumArt(albumUrl: String) {
         guard let url = URL(string: albumUrl) else { return }
         URLSession.shared.dataTask(with: url) { data, _, _ in
             guard let data = data, let image = NSImage(data: data) else { return }
             Task { @MainActor in
                 MusicManager.shared.albumArt = image
                 self.getAverageColor()
             }
         }.resume()
     }
     
     private func getAverageColor() {
         guard let image = MusicManager.shared.albumArt else { return }
         image.averageColor { color in
             if let color = color {
                 MusicManager.shared.aveColor = color
             } else {
                 print("Failed to get average color")
             }
         }
     }
}
