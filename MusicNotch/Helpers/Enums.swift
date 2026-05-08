//
//  Enums.swift
//  MusicNotch
//
//  Created by Noah Johann on 31.12.25.
//

import SwiftUI
import AppKit
import Defaults

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

enum MusicApp: CaseIterable, Codable, Identifiable, Defaults.Serializable {
    case appleMusic
    case spotify
    case nowPlaying
        
    var id: Self { self }
    
    var image: Image {
        switch self {
        case .appleMusic:
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Music") {
                let nsImage = NSWorkspace.shared.icon(forFile: appURL.path)
                nsImage.size = NSSize(width: 64, height: 64)
                return Image(nsImage: nsImage)
            }
            return Image(systemName: "music.note")
        case .spotify:
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.spotify.client") {
                let nsImage = NSWorkspace.shared.icon(forFile: appURL.path)
                nsImage.size = NSSize(width: 64, height: 64)
                return Image(nsImage: nsImage)
            }
            return Image(systemName: "music.note")
        case .nowPlaying:
            if #available(macOS 26, *) {
                if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.apps.launcher") {
                    let nsImage = NSWorkspace.shared.icon(forFile: appURL.path)
                    nsImage.size = NSSize(width: 64, height: 64)
                    return Image(nsImage: nsImage)
                }
            } else {
                if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.launchpad.launcher") {
                    let nsImage = NSWorkspace.shared.icon(forFile: appURL.path)
                    nsImage.size = NSSize(width: 64, height: 64)
                    return Image(nsImage: nsImage)
                }
            }
            return Image(systemName: "music.note")
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


