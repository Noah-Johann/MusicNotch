//
//  openMusicApp.swift
//  MusicNotch
//
//  Created by Noah Johann on 10.01.26.
//

import AppKit
import Defaults

func openMusicApp() {
    switch Defaults[.musicPlayer] {
    case .appleMusic:
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") {
            NSWorkspace.shared.open(url)
        }
    case .spotify:
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client") {
            NSWorkspace.shared.open(url)
        }
    case .nowPlaying:
        Task { @MainActor in
            if let url = MusicManager.shared.playingAppBundle, let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: url) {
                NSWorkspace.shared.open(appURL)
            }
        }
    }
}
