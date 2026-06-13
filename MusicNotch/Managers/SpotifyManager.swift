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

class SpotifyManager {
    static let shared = SpotifyManager()
                        
    public var oldTrackName: String = ""
    
    private var spotifyBundle = "com.spotify.client"

    public func isSpotifyRunning() -> Bool {
        let workspace = NSWorkspace.shared
        
        return workspace.runningApplications.contains { app in
            app.bundleIdentifier == spotifyBundle
        }
    }

    public func isSpotifyInstalled() -> Bool {
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: spotifyBundle) != nil

    }
    
    public func setupObservers() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(spotifyNotification),
            name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil,
            suspensionBehavior: .deliverImmediately
        )
    }
    
    @objc private func spotifyNotification(_ sender: NSNotification?) {
        guard isSpotifyRunning() else { return }
        
        let musicAppKilled = sender?.userInfo?["Player State"] as? String == "Stopped"
        if musicAppKilled {
            Task {
                try? await Task.sleep(for: .milliseconds(1000))
                let running = isSpotifyRunning()
                if running {
                    await MusicManager.shared.updateMusic(player: .spotify)
                } else {
                    if Defaults[.autoPlayer] {
                        guard await MusicManager.shared.musicPlayer == .spotify else { return }
                    } else {
                        guard Defaults[.musicPlayer] == .spotify else { return }
                    }
                    await MusicManager.shared.setDisabledPlayback()
                    return
                }
            }
        } else {
            Task { @MainActor in
                MusicManager.shared.updateMusic(player: .spotify)
            }
        }
    }
    
    public func checkIfPlaying() -> Bool {
        let result = AppleScriptHelper.executeAppleScript("tell application \"Spotify\" to set isPlaying to player state as string")
        if let stringValue = result?.stringValue, stringValue == "playing" {
            return true
        } else {
            return false
        }
    }
          
    public func collectSpotifyInfo() -> MusicTrack? {
        guard isSpotifyRunning() else { return nil }
        
        let script = """
        tell application "Spotify"
            try
                set isPlaying to player state as string
                set trackName to name of current track
                set artistName to artist of current track
                set albumName to album of current track
                set trackDuration to duration of current track / 1000
                set trackPosition to player position
                set currentVolume to sound volume
                set trackID to id of current track
                set shuffle to shuffling
                set repeatVar to repeating
                set typeURL to spotify url of current track
                try
                    set albumArt to artwork url of current track
                on error
                    set albumArt to ""
                end try
                return {isPlaying, trackName, artistName, albumName, trackDuration, trackPosition, currentVolume, trackID, shuffle, repeatVar, typeURL, albumArt}
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
            isLoved: false,
            shuffle: descriptor.atIndex(9)?.booleanValue ?? false,
            repeating: descriptor.atIndex(10)?.stringValue == "true",
            volume: descriptor.atIndex(7) != nil ? CGFloat(descriptor.atIndex(7)!.doubleValue) : nil,
            type: (descriptor.atIndex(11)?.stringValue ?? "").contains("episode") ? .podcast : .music
        )
        print("Spotify Playback Type: \(returnTrack.type)")
                
        if oldTrackName != returnTrack.trackName {
            oldTrackName = returnTrack.trackName
            Task { @MainActor in
                fetchAlbumArt(albumUrl: descriptor.atIndex(12)?.stringValue ?? "")
            }
        }
        return returnTrack
    }
    
    @MainActor private func fetchAlbumArt(albumUrl: String) {
         guard let url = URL(string: albumUrl) else { return }
        
         URLSession.shared.dataTask(with: url) { data, _, _ in
             guard let data = data, let image = NSImage(data: data) else {
                 Task { @MainActor in
                     MusicManager.shared.albumArt = NSImage(named: "no_playback")
                 }
                 return
             }
             Task { @MainActor in
                 MusicManager.shared.albumArt = image
                 image.averageColor { color in
                     MusicManager.shared.aveColor = color
                 }
             }
         }.resume()
     }
}
