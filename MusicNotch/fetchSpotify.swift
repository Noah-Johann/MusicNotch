//
//  fetchSpotify.swift
//  MusicNotch
//
//  Created by Noah Johann on 14.03.25.
//


import Foundation
import AppKit
import Defaults

public var timer = 0
class SpotifyManager: ObservableObject {
    static let shared = SpotifyManager()    
    
    // private var closedView = closedPlayer()
    // private var opendView = OpendPlayer()
    
    // Öffentliche Eigenschaften
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
    private var hideTimer: Timer?
    private var stopTime = 0
    
    
    private init() {
        setupPlaybackObserver()
    }
    
    private func setupPlaybackObserver() {
        // Register for Spotify playback state changes via NSDistributedNotificationCenter
        DistributedNotificationCenter.default().addObserver(self,
                                selector: #selector(playbackStateChanged(_:)),
                                name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
                                object: nil)
    }

    @objc private func playbackStateChanged(_ notification: Notification) {
        self.updateInfo()
    }
    
    
    public func updateInfo() {
        print("update info")
        collectBasicInfo()
        updatePlayIcon()
        updateShuffleIcon()
        fetchAlbumArt()
        
        if self.isPlaying == false {
            let hideNotchTime = Defaults[.hideNotchTime]
            stopTime = 0
            if hideTimer == nil {
                print("start timer")
                hideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    DispatchQueue.main.async {
                        self.stopTime += 1
                        if self.stopTime > Int(hideNotchTime) {
                            self.hideTimer?.invalidate()
                            self.hideTimer = nil
                            print("hideNotch")
                            MusicNotchApp.hideNotch()
                        }
                    }
                }
            }
        }
        
        if self.isPlaying == true  && notchState == "hide" {
            print("shownotch")
            DispatchQueue.main.async() {
                print("shownotch")
                MusicNotchApp.showNotch()

            }
            notchState = "closed"
        }
        
        if self.isPlaying == true && hideTimer != nil {
            self.hideTimer?.invalidate()
            self.hideTimer = nil

        }
    }
    
    public func collectBasicInfo() {
        let script = """
        if application "Spotify" is running then
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
        else
            return {false, "", "", "", 0, 0, false, "", 0, "", "", 0, 0, 0, false, ""}
        end if
        """
        
        let result = executeAppleScript(script)
        // Umwandlung der String-Ausgabe in ein Array
        if let resultString = result as? String {
            
            let cleanedResult = resultString
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "") }
            
            // Falls das letzte Element leer ist, entfernen wir es
            var finalResult = cleanedResult
            if let last = finalResult.last, last.isEmpty {
                finalResult.removeLast()
            }
            


                        
            // Sicherstellen, dass genügend Daten vorhanden sind
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
                //clearAllData()
                print("Error on getting information or spotify not running")
            }
        } else {
            print("Fehler: Didn't get any result")
        }
        
        if !spotifyRunning {
            print("Spotify is not running.")
        }
    }
    
    // Hilfsfunktion zum Zurücksetzen aller Daten
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
    
    // Hilfsfunktion zur Ausführung eines AppleScript-Befehls
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
    
    func fetchAlbumArt() {
        guard let url = URL(string: albumArtURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = NSImage(data: data) else { return }
            DispatchQueue.main.async {
                self.albumArtImage = image
            }
        }.resume()
    }
}
