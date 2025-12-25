//
//  NotchMusicView.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.11.25.
//

import SwiftUI

struct NotchMusicViewLeading: View {
    @ObservedObject private var notchContentState = NotchContentState.shared
    @State private var musicManager = MusicManager.shared
    
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
                AlbumArtView(size: (NSScreen.main?.isOnNotchScreen ?? false) ? 30.0 : 20.0,
                             shrink: 5,
                             cornerRadius: (NSScreen.main?.isOnNotchScreen ?? false) ? 6 : 4,
                             glow: false,
                )
            }) .buttonStyle(.plain)
                .padding(.leading, 3)
            if notchContentState.notchContent == .musicGlance {
                Text(musicManager.music.trackName)
                    .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                    .frame(minWidth: 75, maxWidth: 125)
            }
        }
    }
}

struct NotchMusicViewTrailing: View {
    @ObservedObject private var notchContentState = NotchContentState.shared
    @State private var musicManager = MusicManager.shared

    var body: some View {
        HStack {
            if notchContentState.notchContent == .musicGlance {
                Text(musicManager.music.artistName)
                    .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                    .frame(minWidth: 75, maxWidth: 125)
            }
            
            AudioSpectView()
        }
    }
}


