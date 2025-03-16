//
//  PlayIcon.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation
import CoreAudio

public enum PlayState: String {
    case play
    case pause
}

public var PlayIcon: String = "play.fill"

public func setPlayIcon(for state: PlayState) {
    switch state {
    case .play:
        PlayIcon = "play.fill"
    case .pause:
        PlayIcon = "pause.fill"
    }
}

func updatePlayIcon() {
    if SpotifyManager.shared.isPlaying == true {
        setPlayIcon(for: .pause)
    } else if SpotifyManager.shared.isPlaying == false {
        setPlayIcon(for: .play)
    }
}


