//
//  MusicNotchIntents.swift
//  MusicNotch
//
//  Created by Noah Johann on 21.08.25.
//

import AppIntents

struct TogglePlaybackIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Playback"
    
    func perform() async throws -> some IntentResult {
        spotifyPlayPause()
        return .result()
    }
}

struct SkipForwardIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Forward"
    
    func perform() async throws -> some IntentResult {
        spotifyNextTrack()
        return .result()
    }
}

struct SkipBackwardIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Backwards"
    
    func perform() async throws -> some IntentResult {
        spotifyLastTrack()
        return .result()
    }
}

struct ToggleShuffleIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Shuffle"
    
    func perform() async throws -> some IntentResult {
        spotifyShuffle()
        return .result()
    }
}


