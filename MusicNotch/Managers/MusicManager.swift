//
//  MusicManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 19.12.25.
//

import Foundation
import AppKit
import SwiftUI
import Defaults

@MainActor @Observable
class MusicManager {
    static let shared = MusicManager()
        
    var music = MusicTrack(
        trackName: "",
        artistName: "",
        albumName: "",
        trackDuration: 1,
        trackPosition: 0,
        isPlaying: false,
        isLoved: false,
        shuffle: false,
    )
    var albumArt: NSImage? = NSImage(named: "no_playback")
    var aveColor: NSColor? = .white
    
    private var hideTimer: Timer? = nil
    private var stopTime = 0
    private var launched: Bool = false
    private var prevMusic = MusicTrack(trackName: "", artistName: "", albumName: "", trackDuration: 0, trackPosition: 0, isPlaying: false, isLoved: false, shuffle: false)
    
    init () {        
        setupObservers()
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    private func setupObservers() {
        Task { [weak self] in
            guard let self = self else { return }
            
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(spotifyNotification),
                name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
                object: nil,
                suspensionBehavior: .deliverImmediately
            )
            
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(appleMusicNotification),
                name: NSNotification.Name("com.apple.Music.playerInfo"),
                object: nil,
                suspensionBehavior: .deliverImmediately
            )
        }
    }
    
    @objc private func spotifyNotification(_ sender: NSNotification?) {
        guard Defaults[.musicPlayer] == .spotify else { return }
        
        let musicAppKilled = sender?.userInfo?["Player State"] as? String == "Stopped"
        if musicAppKilled {
            SpotifyManager.shared.isSpotifyRunning = false
            music = disabledPlayback()
            return
        } else {
            SpotifyManager.shared.isSpotifyRunning = true
        }

        
        guard SpotifyManager.shared.isSpotifyRunning && SpotifyManager.shared.checkIfSpotifyIsRunning() else { return }
        updateMusic()
    }
    
    @objc private func appleMusicNotification(_ sender: NSNotification?) {
        guard Defaults[.musicPlayer] == .appleMusic else { return }
        updateMusic()
    }
    
    public func updateMusic() {
        music = getMusicInfo()
        if music.trackName != prevMusic.trackName {
            prevMusic = music
            
            if Defaults[.autoMusicGlance] && NotchManager.shared.notchContent != .musicGlance {
                if launched == false {
                    launched = true
                } else {
                    NotchManager.shared.showExtensionNotch(type: .musicGlance)
                }
            }
        }
        
        if music.isPlaying == true {
            WindowManager.showLockScreenPlayer()
            
            if hideTimer != nil {
                stopTime = 0
                hideTimer?.invalidate()
                hideTimer = nil
            }
            
            if NotchManager.shared.notchState == .closed || NotchManager.shared.notchState == .transparent {
                guard !NotchManager.shared.notchDismissed else { return }
                
                if Defaults[.autoMusicGlance] {
                    NotchManager.shared.showExtensionNotch(type: .musicGlance)
                } else {
                    NotchManager.shared.notchContent = .music
                    Task {
                        await NotchManager.shared.setNotchState(.compact, false)
                    }
                }
            }
        }
        
        if music.isPlaying == false {
            if NotchManager.shared.notchDismissed == true {
                NotchManager.shared.notchDismissed = false
            }
            
            if hideTimer == nil {
                if NotchManager.shared.notchContent == .music || NotchManager.shared.notchContent == .musicGlance {
                    if NotchManager.shared.notchDismissed == false && NotchManager.shared.notchState == .compact {
                        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                            guard let self = self else { return }
                            Task { @MainActor in
                                self.stopTime += 1
                                print(self.stopTime)
                                if self.stopTime > Int(Defaults[.hideNotchTime]) && NotchManager.shared.notchState == .compact {
                                    guard NotchManager.shared.notchContent == .music || NotchManager.shared.notchContent == .musicGlance else { return }
                                    Task {
                                        await NotchManager.shared.setNotchState(.closed, false)
                                    }
                                    self.hideTimer?.invalidate()
                                    self.hideTimer = nil
                                    self.stopTime = 0
                                    
                                }
                            }
                        }
                    }
                }
            } else if hideTimer != nil {
                if NotchManager.shared.notchState == .closed || NotchManager.shared.notchState == .transparent {
                    self.hideTimer?.invalidate()
                    self.hideTimer = nil
                    self.stopTime = 0
                }
            }
        }
    }
    
    private func getMusicInfo() -> MusicTrack {
        switch Defaults[.musicPlayer] {
        case .appleMusic:
            if let info = AppleMusicManager.shared.collectAppleMusicInfo() {
                return info
            } else {
                return disabledPlayback()
            }
            
        case .spotify:
            if let info = SpotifyManager.shared.collectSpotifyInfo() {
                return info
            } else {
                return disabledPlayback()
            }
        case .nowPlaying:
            if let info = SpotifyManager.shared.collectSpotifyInfo() {
                return info
            } else {
                return disabledPlayback()
            }
        }
    }
    
    private func disabledPlayback() -> MusicTrack {
        let playback = MusicTrack(trackName: "Nothing playing",
                           artistName: "No current playback",
                           albumName: "Nothing",
                           trackDuration: 1,
                           trackPosition: 0,
                           isPlaying: false,
                           isLoved: false,
                           shuffle: false,
        )
        
        Task { @MainActor in
            self.albumArt = NSImage(named: "no_playback")
        }
        if NotchManager.shared.notchContent == .musicGlance || NotchManager.shared.notchContent == .music {
            Task {
                await NotchManager.shared.setNotchState(.closed, false)
            }
        }
        
        WindowManager.hideLockScreen()
        
        return playback
    }
    
    public func getAverageColor() {
        guard let image = self.albumArt else { return }
        image.averageColor { color in
            if let color = color {
                self.aveColor = color
            } else {
                print("Failed to get average color")
            }
        }
    }
    
}

// MARK: - Constants

struct MusicTrack {
    var trackName: String
    var artistName: String
    var albumName: String
    var trackDuration: Int
    var trackPosition: Int
    var isPlaying: Bool
    var isLoved: Bool
    var shuffle: Bool
}
