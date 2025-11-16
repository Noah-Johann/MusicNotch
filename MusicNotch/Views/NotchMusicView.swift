//
//  NotchMusicView.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.11.25.
//

import SwiftUI

struct NotchMusicViewLeading: View {
    @ObservedObject private var notchContentState = NotchContentState.shared
    @ObservedObject private var spotifyManager = SpotifyManager.shared
    
    var body: some View {
        HStack {
            AlbumArtView(sizeState: "closed")
            
            if notchContentState.notchContent == .musicGlance {
                Text(spotifyManager.trackName)
                    .foregroundStyle(Color(spotifyManager.aveColor ?? .white).gradient)
                    .frame(minWidth: 75, maxWidth: 125)
            }
        }
    }
}

struct NotchMusicViewTrailing: View {
    @ObservedObject private var notchContentState = NotchContentState.shared
    @ObservedObject private var spotifyManager = SpotifyManager.shared

    var body: some View {
        HStack {
            if notchContentState.notchContent == .musicGlance {
                Text(spotifyManager.artistName)
                    .foregroundStyle(Color(spotifyManager.aveColor ?? .white).gradient)
                    .frame(minWidth: 75, maxWidth: 125)
            }
            
            AudioSpectView()
        }
    }
}


