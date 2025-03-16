//
//  ShuffleIcon.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.03.25.
//

import Foundation

public enum ShuffleState: String {
    case on
    case off
}

public var ShuffleIcon: String = "shuffle.circle"

public func setShuffleIcon(for state: ShuffleState) {
    switch state {
    case .on:
        ShuffleIcon = "shuffle.circle.fill"
    case .off:
        ShuffleIcon = "shuffle.circle"
    }
}

func updateShuffleIcon() {
    if SpotifyManager.shared.shuffle == true {
        setShuffleIcon(for: .on)
    } else if SpotifyManager.shared.shuffle == false {
        setShuffleIcon(for: .off)
    }
}

