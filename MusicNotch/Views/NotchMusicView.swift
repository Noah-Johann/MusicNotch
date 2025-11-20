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
            Button (action: {
                if notchContentState.notchContent == .music {
                    withAnimation(.bouncy(duration: 0.6)) {
                        NotchContentState.shared.notchContent = .musicGlance
                    }
                } else if notchContentState.notchContent == .musicGlance {
                    withAnimation(.bouncy(duration: 0.6)) {
                        NotchContentState.shared.notchContent = .music
                    }
                } else {
                    return
                }
            }, label: {
                AlbumArtView(sizeState: "closed")
            }) .buttonStyle(.plain)
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


