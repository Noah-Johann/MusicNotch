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
    @Published var trackURL: String = ""
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
            
            if finalResult.count >= 12 {
                self.spotifyRunning = finalResult[0] == "true"
                self.isPlaying = finalResult[1] == "playing"
                self.trackName = finalResult[2]
                self.artistName = finalResult[3]
                self.albumName = finalResult[4]
                self.trackDuration = Int(Double(finalResult[5]) ?? 0)
                self.trackPosition = Int(Double(finalResult[6]) ?? 0)
                self.isLoved = finalResult[7] == "true"
                self.trackId = finalResult[8]
                self.trackURL = finalResult[9]
                self.shuffle = finalResult[10] == "true"
                self.albumArtURL = finalResult[11]
                
                
            } else {
                self.spotifyRunning = false
                print("Error on getting information or spotify not running")
            }
        } else {
            print("Fehler: Didn't get any result")
        }
        
        if !spotifyRunning {
            print("Spotify is not running.")
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
        guard let image = self.albumArtImage else { return }
        image.averageColor { color in
            if let color = color {
                self.aveColor = color
            } else {
                print("Failed to get average color")
            }
        }
    }
}
