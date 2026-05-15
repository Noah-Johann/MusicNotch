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
import MediaRemoteAdapter

@MainActor @Observable
class MusicManager {
    static let shared = MusicManager()
    
    let mediaController = MediaController()
    
    var musicPlayer: MusicApp = .nowPlaying
        
    var music = MusicTrack(
        trackName: "",
        artistName: "",
        albumName: "",
        trackDuration: 1,
        trackPosition: 0,
        isPlaying: false,
        isLoved: false,
        shuffle: false,
        type: .music,
    )
    var albumArt: NSImage? = NSImage(named: "no_playback")
    var aveColor: NSColor? = .white
    var playingAppName: String? = nil
    var playingAppBundle: String? = nil
    
    private var hideTimer: Timer? = nil
    private var stopTime = 0
    private var launched: Bool = false
    private var prevMusic = MusicTrack(trackName: "", artistName: "", albumName: "", trackDuration: 0, trackPosition: 0, isPlaying: false, isLoved: false, shuffle: false, type: .music)
    
    private let appleMusicManager = AppleMusicManager()
    private let spotifyManager = SpotifyManager()
    
    private var enableMusicGlance: Bool {
        if Defaults[.allPlayerMusicGlanceSetting] == true {
            return Defaults[.globalMusicGlance]
        } else {
            switch self.musicPlayer {
            case .appleMusic: return Defaults[.amMusicGlance]
            case .spotify: return Defaults[.spotifyMusicGlance]
            case .nowPlaying: return Defaults[.npMusicGlance]
            }
        }
    }
    
    init () {
        if Defaults[.autoPlayer] {
            self.musicPlayer = .nowPlaying
        } else {
            self.musicPlayer = Defaults[.musicPlayer]
        }
        
        appleMusicManager.setupObservers()
        spotifyManager.setupObservers()
        Task {
            mediaController.startListening()
        }
        
        mediaController.onTrackInfoReceived = { trackInfo in
            Task {
                self.updateMusic(player: .nowPlaying, updateInfo: trackInfo)
            }
        }
        mediaController.onListenerTerminated = {
            self.music = self.disabledPlayback()
            print("Listener terminated")
        }
    }
    
    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
        mediaController.stopListening()
    }
    
    // MARK: - Public

    /// Refreshes the music info for the last playing player or selected player
    public func refreshMusic() {
        updateMusic(player: musicPlayer)
    }
    
    /// Updates the music info for a specified player and optional updateInfo for now playing info
    public func updateMusic(player: MusicApp, updateInfo: TrackInfo? = nil) {
        if Defaults[.autoPlayer] {
            checkAutoPlayer(notificationPlayer: player, updateInfo: updateInfo)
        } else {
            guard player == Defaults[.musicPlayer] else { return }
            if Defaults[.musicPlayer] == .nowPlaying {
                if let info = updateInfo {
                    setNowPlayingInfo(trackInfo: info)
                } else {
                    mediaController.getTrackInfo() { trackInfo in
                        self.setNowPlayingInfo(trackInfo: trackInfo)
                    }
                }
            } else {
                withAnimation(.bouncy(duration: 0.4)) {
                    self.music = getMusicInfo(player: player)
                }
            }
        }
        
        processMusicInfo()
    }
    
    // MARK: - Private

    /// Fetch the music and set the correct player when auto player is enabled
    private func checkAutoPlayer(notificationPlayer: MusicApp, updateInfo: TrackInfo? = nil) {
        guard Defaults[.autoPlayer] else { return }
        
        let prevPlayer = musicPlayer
        
        switch notificationPlayer {
        case .appleMusic:
            musicPlayer = .appleMusic
            withAnimation(.bouncy(duration: 0.4)) {
                self.music = getMusicInfo(player: .appleMusic)
            }
        case .spotify:
            musicPlayer = .spotify
            withAnimation(.bouncy(duration: 0.4)) {
                self.music = getMusicInfo(player: .spotify)
            }
        case .nowPlaying:
            if updateInfo != nil {
                guard updateInfo?.payload.bundleIdentifier != "com.spotify.client" && updateInfo?.payload.bundleIdentifier != "com.apple.Music" else { print("supported player"); return }
            }
            
            // Check if prev player is still playing
            if prevPlayer == .appleMusic {
                if appleMusicManager.checkIfPlaying() { print("AM running"); return }
            } else if prevPlayer == .spotify {
                if spotifyManager.checkIfPlaying() { print("Spotify running"); return }
            }
            
            musicPlayer = .nowPlaying
            if let info = updateInfo {
                setNowPlayingInfo(trackInfo: info)
            } else {
                mediaController.getTrackInfo() { trackInfo in
                    guard updateInfo?.payload.bundleIdentifier != "com.spotify.client" && updateInfo?.payload.bundleIdentifier != "com.apple.Music" else { return }
                    self.setNowPlayingInfo(trackInfo: trackInfo)
                }
            }
        }
    }
    
    private func processMusicInfo() {
        if music.trackName != prevMusic.trackName {
            prevMusic = music
            
            if enableMusicGlance && music.isPlaying == true {
                if launched == false {
                    launched = true
                } else {
                    NotchManager.shared.showExtensionNotch(type: .musicGlance, duration: Defaults[.musicGlanceDuration])
                }
            }
        }
        
        if music.isPlaying == true {
            WindowManager.shared.showLockScreenPlayer()
            
            if hideTimer != nil {
                stopTime = 0
                hideTimer?.invalidate()
                hideTimer = nil
            }
            
            if NotchManager.shared.notchState == .closed || NotchManager.shared.notchState == .transparent {
                guard !NotchManager.shared.notchDismissed else { return }
                
                if enableMusicGlance {
                    NotchManager.shared.showExtensionNotch(type: .musicGlance, duration: Defaults[.musicGlanceDuration])
                } else {
                    NotchManager.shared.notchContent = .music
                    Task {
                        await NotchManager.shared.setNotchState(.compact)
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
                                if NotchManager.shared.notchState == .compact {
                                    if self.stopTime > Int(Defaults[.hideNotchTime]) {
                                        guard NotchManager.shared.notchContent == .music else { return }
                                        await NotchManager.shared.setNotchState(.closed)
                                        self.hideTimer?.invalidate()
                                        self.hideTimer = nil
                                        self.stopTime = 0
                                        
                                    }
                                } else {
                                    self.hideTimer?.invalidate()
                                    self.hideTimer = nil
                                    self.stopTime = 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Gets the music info with AppleScript for Apple Music and Spotify
    private func getMusicInfo(player: MusicApp) -> MusicTrack {
        switch player {
        case .appleMusic:
            if let info = AppleMusicManager.shared.collectAppleMusicInfo() {
                self.playingAppName = "Music"
                self.playingAppBundle = "com.apple.Music"
                self.musicPlayer = .appleMusic
                return info
            } else {
                return disabledPlayback()
            }
            
        case .spotify:
            if let info = SpotifyManager.shared.collectSpotifyInfo() {
                self.playingAppName = "Spotify"
                self.playingAppBundle = "com.spotify.client"
                self.musicPlayer = .spotify
                return info
            } else {
                return disabledPlayback()
            }
        case .nowPlaying:
            print("Get music info with now playing")
            return disabledPlayback()
        }
    }

    /// Sets the music for the now playing source
    private func setNowPlayingInfo(trackInfo: TrackInfo?) {
        guard let trackInfo = trackInfo else {
            setDisabledPlayback()
            return
        }
        
        withAnimation(.bouncy(duration: 0.4)) {
            self.music = MusicTrack(trackName: trackInfo.payload.title ?? "",
                                    artistName: trackInfo.payload.artist ?? "",
                                    albumName: trackInfo.payload.album ?? "",
                                    trackDuration: Int(trackInfo.payload.durationMicros ?? 1) / 1000000,
                                    trackPosition: Int(trackInfo.payload.elapsedTimeMicros ?? 0) / 1000000,
                                    isPlaying: trackInfo.payload.isPlaying ?? false,
                                    isLoved: false,
                                    shuffle: false,
                                    type: trackInfo.payload.bundleIdentifier == "com.apple.podcasts" ? .podcast : .music,
            )
        }
        
        if trackInfo.payload.artwork != nil {
            self.albumArt = trackInfo.payload.artwork
            self.getAverageColor()
        }
        
        self.playingAppName = trackInfo.payload.applicationName
        self.playingAppBundle = trackInfo.payload.bundleIdentifier
    }
    
    // MARK: - Disabled Playback
    
    public func setDisabledPlayback() {
        withAnimation(.bouncy(duration: 0.4)) {
            music = disabledPlayback()
        }
    }
    
    private func disabledPlayback() -> MusicTrack {
        let prevPlayback = self.music
            let playback = MusicTrack(trackName: "Nothing playing",
                                      artistName: "No current playback",
                                      albumName: "Nothing",
                                      trackDuration: 1,
                                      trackPosition: 0,
                                      isPlaying: false,
                                      isLoved: false,
                                      shuffle: false,
                                      type: .music,
            )
        playingAppName = nil
        playingAppBundle = nil
        musicPlayer = .nowPlaying
        
        Task { @MainActor in
            self.albumArt = NSImage(named: "no_playback")
            SpotifyManager.shared.oldTrackName = ""
        }
        
        if NotchManager.shared.notchContent == .musicGlance || NotchManager.shared.notchContent == .music {
            Task {
                if prevPlayback.trackName != "Nothing playing" {
                    await NotchManager.shared.setNotchState(.closed)
                }
            }
        }
        
        WindowManager.shared.hideLockScreen()
        
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
    
// MARK: - Now Playing Controls
    
    func NPplay() { mediaController.play() }
    func NPpause() { mediaController.pause() }
    func NPtogglePlayPause() { mediaController.togglePlayPause() }
    func NPnextTrack() { mediaController.nextTrack() }
    func NPpreviousTrack() { mediaController.previousTrack() }
    func NPstop() { mediaController.stop() }
    func NPseek(to seconds: Double) { mediaController.setTime(seconds: seconds) }

    func NPsetShuffle(_ mode: TrackInfo.ShuffleMode) { mediaController.setShuffleMode(mode) }
    func NPsetRepeat(_ mode: TrackInfo.RepeatMode) { mediaController.setRepeatMode(mode) }
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
    var volume: CGFloat?
    var type: PlaybackType
}

enum PlaybackType {
    case music
    case podcast
}
