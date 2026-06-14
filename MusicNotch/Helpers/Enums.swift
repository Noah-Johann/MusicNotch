//
//  Enums.swift
//  MusicNotch
//
//  Created by Noah Johann on 31.12.25.
//

import SwiftUI
import AppKit
import Defaults

// MARK: - Display

enum Display: CaseIterable, Codable, Defaults.Serializable {
    case notchDisplay
    case mainDisplay
    
    var image: Image {
        switch self {
        case .notchDisplay: Image(systemName: "macbook")
                .resizable()
        case .mainDisplay: Image(systemName: "display.2")
                .resizable()
        }
    }
    
    var text: LocalizedStringKey {
        switch self {
        case .notchDisplay: "Notch display"
        case .mainDisplay: "Main display"
        }
    }
}

// MARK: - HoverBehavior

enum HoverBehavior: CaseIterable, Codable, Defaults.Serializable {
    case disabled
    case expand
    case musicGlance
    
    var image: Image {
        switch self {
        case .disabled: Image(systemName: "nosign")
        case .expand: Image(systemName: "arrow.uturn.down")
        case .musicGlance: Image(systemName: "music.note")
        }
    }
    
    var text: LocalizedStringKey {
        switch self {
        case .disabled: "Disabled"
        case .expand: "Expand"
        case .musicGlance: "MusicGlance"
        }
    }
}

// MARK: - MusicApp

enum MusicApp: CaseIterable, Codable, Identifiable, Defaults.Serializable {
    case appleMusic
    case spotify
    case nowPlaying
        
    var id: Self { self }
    
    var image: Image {
        switch self {
        case .appleMusic: Self.appleMusicImage
        case .spotify: Self.spotifyImage
        case .nowPlaying: Self.nowPlayingImage
        }
    }
    
    var text: LocalizedStringKey {
        switch self {
        case .appleMusic: "Apple Music"
        case .spotify: "Spotify"
        case .nowPlaying: "System"
        }
    }
    
}

private extension MusicApp {
    static let appleMusicImage = appIcon(
        bundleIdentifier: "com.apple.Music",
        fallbackAssetName: "Music_AppIcon"
    )
    
    static let spotifyImage = appIcon(
        bundleIdentifier: "com.spotify.client",
        fallbackAssetName: "Spotify_AppIcon"
    )
    
    static let nowPlayingImage: Image = {
        if #available(macOS 26, *) {
            return appIcon(bundleIdentifier: "com.apple.apps.launcher")
        } else {
            return appIcon(bundleIdentifier: "com.apple.launchpad.launcher")
        }
    }()
    
    static func appIcon(bundleIdentifier: String, fallbackAssetName: String? = nil) -> Image {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return Image(nsImage: resizedIcon(NSWorkspace.shared.icon(forFile: appURL.path)))
        }
        
        if let fallbackAssetName, let nsImage = NSImage(named: fallbackAssetName) {
            return Image(nsImage: resizedIcon(nsImage))
        }
        
        return Image(systemName: "music.note")
    }
    
    static func resizedIcon(_ image: NSImage) -> NSImage {
        let copy = image.copy() as? NSImage ?? image
        copy.size = NSSize(width: 64, height: 64)
        return copy
    }
}

// MARK: - MusicAction

enum MusicAction: Codable, CaseIterable, Defaults.Serializable {
    case shuffle
    case repeating
    
    var image: Image {
        switch self {
            case .shuffle: return Image(systemName: "shuffle").resizable()
            case .repeating: return Image(systemName: "repeat").resizable()
        }
    }
    
    var title: LocalizedStringKey {
        switch self {
            case .shuffle: return "Shuffle"
            case .repeating: return "Repeat"
        }
    }
}


