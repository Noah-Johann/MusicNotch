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
        playPause()
        return .result()
    }
}

struct SkipForwardIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Forward"
    
    func perform() async throws -> some IntentResult {
        nextTrack()
        return .result()
    }
}

struct SkipBackwardIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Backwards"
    
    func perform() async throws -> some IntentResult {
        lastTrack()
        return .result()
    }
}

struct ToggleShuffleIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Shuffle"
    
    func perform() async throws -> some IntentResult {
        toggleShuffle()
        return .result()
    }
}


