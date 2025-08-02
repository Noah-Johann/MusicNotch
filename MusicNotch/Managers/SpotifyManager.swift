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
        
    @Published var spotifyRunning: Bool = false
    @Published var isPlaying: Bool = false
    @Published var trackName: String = ""
    @Published var artistName: String = ""
    @Published var albumName: String = ""
    @Published var trackDuration: Int = 30 // in Sekunden
    @Published var trackPosition: Int = 5 // in Sekunden
    @Published var isLoved: Bool = false
    @Published var volume: Int = 0 // 0-100
    @Published var trackURL: String = ""
    @Published var shuffle: Bool = false
    @Published var albumArtURL: String = ""
    @Published var albumArtImage: NSImage? = nil
    @Published var aveColor: NSColor? = nil
    
    @Published var timer = 0
    
    private var oldTrackName: String = ""
    private var hideTimer: Timer?
    private var stopTime = 0
    private var isObserving: Bool = false
    
    
    private init() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setupNotifications()
            
            if self.isSpotifyRunning() {
                self.setupSpotifyObservers()
            }
        }
    }
    
    deinit {
        Task { [weak self] in
            await self?.cleanup()
        }
    }
    
    private func setupNotifications() {
        // Listen for application launched notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(applicationLaunched(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        
        // Listen for application terminated notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(applicationTerminated(_:)),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )
    }
    
    @objc private func applicationLaunched(_ notification: Notification) {
        // Check if the launched application is Spotify
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let appName = app.localizedName,
           appName.localizedCaseInsensitiveContains("Spotify") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                if !self.isObserving && self.isSpotifyRunning() {
                    self.setupSpotifyObservers()
                }
            }
        }
    }
    
    @objc private func applicationTerminated(_ notification: Notification) {
        // Check if the terminated application is Spotify
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let appName = app.localizedName,
           appName.localizedCaseInsensitiveContains("Spotify") {
            self.stopObserving()
        }
    }
    
    private func stopObserving() {
        if isObserving {
            DistributedNotificationCenter.default().removeObserver(self)
            isObserving = false
        }
        
        if hideTimer != nil {
            hideTimer?.invalidate()
            hideTimer = nil
        }
    }
    
    public func cleanup() {
        stopObserving()
        clearAllData()
        
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    private func setupSpotifyObservers() {
        // Don't set up observers if already observing
        guard !isObserving else { return }
        
        // Only set up if Spotify is actually running
        guard isSpotifyRunning() else { return }
                
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(self.playbackStateChanged(_:)),
                name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
                object: nil
            )
            
            self.isObserving = true
            self.updateInfo()
        }
    }

    @objc private func playbackStateChanged(_ notification: Notification) {
        if isSpotifyRunning() {
            self.updateInfo()
        } else {
            stopObserving()
            clearAllData()
        }
    }
    
    private func isSpotifyRunning() -> Bool {
        let script = """
        tell application "System Events"
            set spotifyProcess to (exists process "Spotify")
            if spotifyProcess then
                return true
            else
                return false
            end if
        end tell
        """
        
        if let result = executeAppleScript(script) as? String {
            let isRunning = result.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
            self.spotifyRunning = isRunning
            return isRunning
        }
        return false
    }
    
    public func updateInfo() {
        if !isSpotifyRunning() {
            clearAllData()
            stopObserving() 
            return
        }
        
        collectBasicInfo()
        
        if self.trackName != oldTrackName {
            oldTrackName = self.trackName
            fetchAlbumArt(artURL: self.albumArtURL) { image in
                if let image = image {
                    Task { @MainActor in
                        self.albumArtImage = image
                        
                        getAverageColor(image: image) { color in
                            if let color = color {
                                Task { @MainActor in
                                    self.aveColor = color
                                }
                            } else {
                                print("Error getting album art color")
                            }
                        }
                    }
                } else {
                    print("Error getting album art")
                }
            }
        }
        
        let hideNotchTime = Defaults[.hideNotchTime]
        stopTime = 0
        if hideTimer == nil && self.isPlaying == false {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.stopTime += 1
                    if self.stopTime > Int(hideNotchTime) && NotchManager.shared.notchState == "closed" {
                        self.hideTimer?.invalidate()
                        self.hideTimer = nil
                        NotchManager.shared.setNotchContent(.hidden, false)
                        NotchManager.shared.notchState = "hide"
                    }
                }
            }
        }
        
        if self.isPlaying == true && NotchManager.shared.notchState == "hide" {
            DispatchQueue.main.async() {
                NotchManager.shared.setNotchContent(.closed, false)
            }
        }
        
        if self.isPlaying == true && hideTimer != nil {
            self.hideTimer?.invalidate()
            self.hideTimer = nil
        }
    }
    
    public func collectBasicInfo() {
        if !isSpotifyRunning() {
            stopObserving()
            clearAllData()
            return
        }
        
        let script = """
        tell application "System Events"
            if exists process "Spotify" then
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
            else
                return {false, "", "", "", 0, 0, false, "", 0, "", "", 0, 0, 0, false, ""}
            end if
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
                self.volume = Int(finalResult[8]) ?? 0
                self.trackURL = finalResult[9]
                self.shuffle = finalResult[10] == "true"
                self.albumArtURL = finalResult[11]
                
                
            } else {
                self.spotifyRunning = false
                clearAllData()
                print("Error on getting information or spotify not running")
                stopObserving()
            }
            
        } else {
            print("Fehler: Didn't get any result")
            self.spotifyRunning = false
            clearAllData()
            stopObserving()
        }
        
        if !spotifyRunning {
            print("Spotify is not running.")
            stopObserving()
        }
    }
    
    private func clearAllData() {
//        isPlaying = false
//        trackName = "Nothing playing"
//        artistName = ""
//        albumName = ""
//        trackDuration = 0
//        trackPosition = 0
//        isLoved = false
//        volume = 0
//        trackURL = ""
//        albumArtURL = ""
//        albumArtImage = nil
//        aveColor = nil
        oldTrackName = ""
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
}
