//
//  fetchSpotify.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//


import Foundation
import AppKit
import Defaults
import SwiftUI

//xpublic var timer = 0
class SpotifyManager: ObservableObject {
    static let shared = SpotifyManager()    
        
    @Published var spotifyRunning: Bool = false
    @Published var isPlaying: Bool = false
    @Published var trackName: String = ""
    @Published var artistName: String = ""
    @Published var albumName: String = ""
    @Published var trackDuration: Int = 30 // in Sekunden
    @Published var trackPosition: Int = 5 // in Sekunden
    @Published var isLoved: Bool = false
    @Published var trackId: String = ""
    @Published var volume: Int = 0 // 0-100
    @Published var trackURL: String = ""
    @Published var releaseDate: String = ""
    @Published var discNumber: Int = 0
    @Published var trackNumber: Int = 0
    @Published var popularity: Int = 0
    @Published var shuffle: Bool = false
    @Published var albumArtURL: String = ""
    @Published var albumArtImage: NSImage? = nil
    @Published var aveColor: NSColor? = nil
    
    @Published var timer: Int = 0
    
    private var oldTrackName: String = ""
    private var hideTimer: Timer?
    private var stopTime = 0
    
    
    private init() {
        setupSpotifyObservers()
        
        if isSpotifyRunning() {
            updateInfo()
        }
        
        updateInfo()
    }
    
    deinit {
        cleanup()
    }

    public func cleanup() {
        DistributedNotificationCenter.default().removeObserver(self)
        
        if hideTimer != nil {
            hideTimer?.invalidate()
            hideTimer = nil
        }
        
        clearAllData()
        
    }
    
    private func setupSpotifyObservers() {
                
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(updateInfo),
                name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
                object: nil
            )
        }
    }
    
    private func isSpotifyRunning() -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { $0.bundleIdentifier == "com.spotify.client" }
    }
    
    @objc public func updateInfo() {
        
        print("update info")
        
        guard isSpotifyRunning() else { return }
        
        collectBasicInfo()
        
        if self.trackName != oldTrackName {
            oldTrackName = self.trackName
            fetchAlbumArt()
        }
        
        let hideNotchTime = Defaults[.hideNotchTime]
        stopTime = 0
        if hideTimer == nil && self.isPlaying == false {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.stopTime += 1
                    if self.stopTime > Int(hideNotchTime) && NotchManager.shared.notchState == .closed {
                        self.hideTimer?.invalidate()
                        self.hideTimer = nil
                        NotchManager.shared.setNotchContent(.hidden, false)
                    }
                }
            }
        }
        
        // Open notch when playback starts
        Task { @MainActor in
            if self.isPlaying == true && NotchManager.shared.notchState == .hidden {
                NotchManager.shared.setNotchContent(.closed, false)
            }
        }
        
        // Remove Nothing-Playing-Timer
        if self.isPlaying == true && hideTimer != nil {
            self.hideTimer?.invalidate()
            self.hideTimer = nil
        }
    }
    
    private func collectBasicInfo() {

        guard isSpotifyRunning() else { return }
        
        print("execute apple script")
        
        let script = """
                tell application "Spotify"
                    set results to {}
                    set end of results to true -- spotifyRunning
                    
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
                        set soundVolume to sound volume
                        set end of results to soundVolume
                    on error
                        set end of results to 0
                    end try
                    
                    try
                        set trackURL to spotify url of current track
                        set end of results to trackURL
                    on error
                        set end of results to ""
                    end try
                    
                    try
                        set releaseDate to year of current track
                        set end of results to releaseDate as string
                    on error
                        set end of results to ""
                    end try
                    
                    try
                        set discNumber to disc number of current track
                        set end of results to discNumber
                    on error
                        set end of results to 0
                    end try
                    
                    try
                        set trackNumber to track number of current track
                        set end of results to trackNumber
                    on error
                        set end of results to 0
                    end try
                    
                    try
                        set popularity to popularity of current track
                        set end of results to popularity
                    on error
                        set end of results to 0
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
            
            if finalResult.count >= 17 {
                self.spotifyRunning = finalResult[0] == "true"
                self.isPlaying = finalResult[1] == "playing"
                self.trackName = finalResult[2]
                self.artistName = finalResult[3]
                self.albumName = finalResult[4]
                self.trackDuration = Int(Double(finalResult[5]) ?? 0)
                self.trackPosition = Int(Double(finalResult[6]) ?? 0)
                self.isLoved = finalResult[7] == "true"
                self.trackId = finalResult[8]
                self.volume = Int(finalResult[9]) ?? 0
                self.trackURL = finalResult[10]
                self.releaseDate = finalResult[11]
                self.discNumber = Int(finalResult[12]) ?? 0
                self.trackNumber = Int(finalResult[13]) ?? 0
                self.popularity = Int(finalResult[14]) ?? 0
                self.shuffle = finalResult[15] == "true"
                self.albumArtURL = finalResult[16]
                
                
            } else {
                self.spotifyRunning = false
                print("Error on getting information or spotify not running")
            }
        } else {
            print("Fehler: Didn't get any result")
            self.spotifyRunning = false
        }
        
        if !spotifyRunning {
            print("Spotify is not running.")
        }
    }
    
    private func clearAllData() {
        isPlaying = false
        trackName = ""
        artistName = ""
        albumName = ""
        trackDuration = 0
        trackPosition = 0
        isLoved = false
        trackId = ""
        volume = 0
        trackURL = ""
        releaseDate = ""
        discNumber = 0
        trackNumber = 0
        popularity = 0
        albumArtURL = ""
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
    
    private func fetchAlbumArt() {
        guard let url = URL(string: albumArtURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = NSImage(data: data) else { return }
            DispatchQueue.main.async {
                self.albumArtImage = image
                self.getAverageColor()
            }
        }.resume()
    }
    
    private func getAverageColor() {
        if let image = self.albumArtImage {
            image.averageColor { color in
                if let color = color {
                    //print("Average color: \(color)")
                    self.aveColor = color
                } else {
                    print("Failed to get average color")
                }
            }
        }
    }
}
