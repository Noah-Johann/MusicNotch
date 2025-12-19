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

@MainActor
class MusicManager {
    static let shared = MusicManager()
    
    private var hideTimer: Timer?
    private var stopTime = 0
    private var launched: Bool = false
    
    @Published var music = MusicTrack(
        trackName: "",
        artistName: "",
        albumName: "",
        trackDuration: 0,
        trackPosition: 0,
        isPlaying: false,
        isLoved: false,
        shuffle: false,
    )
    
    private var prevMusic = MusicTrack(trackName: "", artistName: "", albumName: "", trackDuration: 0, trackPosition: 0, isPlaying: false, isLoved: false, shuffle: false)
    
    init () {
        prevMusic = getMusicInfo()
        
        setupObservers()
        
        updateMusic()
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
        }
    }
    
    @objc private func spotifyNotification(notification: Notification) {
        guard Defaults[.musicPlayer] == .spotify else { return }
        updateMusic()
    }
    
    public func updateMusic() {
        music = getMusicInfo()
        if music.trackName != prevMusic.trackName {
            prevMusic = music
            
            if Defaults[.autoMusicGlance] && NotchContentState.shared.notchContent != .musicGlance {
                //                if launched == false {
                //                    launched = true
                //                } else {
                //                    NotchManager.shared.showExtensionNotch(type: .musicGlance)
                //                }
                NotchManager.shared.showExtensionNotch(type: .musicGlance)
            }
            
            if music.isPlaying == true {
                WindowManager.showLockScreenPlayer()
                
                if NotchManager.shared.notchDismissed == true {
                    NotchManager.shared.notchDismissed = false
                }
                
                if NotchManager.shared.notchState == .closed || NotchManager.shared.notchState == .transparent {
                    guard !NotchManager.shared.notchDismissed else { return }
                    
                    if Defaults[.autoMusicGlance] {
                        NotchManager.shared.showExtensionNotch(type: .musicGlance)
                    } else {
                        NotchContentState.shared.notchContent = .music
                        Task {
                            await NotchManager.shared.setNotchState(.compact, false)
                        }
                    }
                }
            }
            
            if music.isPlaying == false {
                if hideTimer == nil {
                    if NotchContentState.shared.notchContent == .music || NotchContentState.shared.notchContent == .musicGlance {
                        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                            guard let self = self else { return }
                            Task { @MainActor in
                                self.stopTime += 1
                                if self.stopTime > Int(Defaults[.hideNotchTime]) && NotchManager.shared.notchState == .compact {
                                    guard NotchContentState.shared.notchContent == .music || NotchContentState.shared.notchContent == .musicGlance else { return }
                                    self.hideTimer?.invalidate()
                                    self.hideTimer = nil
                                    self.stopTime = 0
                                    Task {
                                        await NotchManager.shared.setNotchState(.closed, false)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                } else if hideTimer != nil {
                    stopTime = 0
                    self.hideTimer?.invalidate()
                    self.hideTimer = nil
                }
            }
        }
    }
    
    private func getMusicInfo() -> MusicTrack {
        switch Defaults[.musicPlayer] {
        case .appleMusic:
            if let info = SpotifyManager.shared.collectSpotifyInfo() {
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
                           trackDuration: 0,
                           trackPosition: 0,
                           aveColor: .white,
                           isPlaying: false,
                           isLoved: false,
                           shuffle: false,
        )
        
        if NotchContentState.shared.notchContent == .musicGlance || NotchContentState.shared.notchContent == .music {
            Task {
                await NotchManager.shared.setNotchState(.closed, false)
            }
        }
        
        WindowManager.hideLockScreen()
        
        return playback
    }
    
}

// MARK: - Constants

struct MusicTrack {
    @State var trackName: String
    var artistName: String
    var albumName: String
    var trackDuration: Int
    var trackPosition: Int
    var albumArt: NSImage?
    var aveColor: NSColor?
    @State var isPlaying: Bool
    var isLoved: Bool
    var shuffle: Bool
}

enum MusicApp: String, Codable, Defaults.Serializable {
    case appleMusic, spotify, nowPlaying
}
