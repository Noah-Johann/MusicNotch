//
//  AlbumArtView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI
import Defaults

struct AlbumArtView: View {
    
    var size: Double
    var shrink: Double
    var cornerRadius: Double
    var glow: Bool
    
    @ObservedObject var spotifyManager = SpotifyManager.shared

    @State private var artworkSize: Double = 0
    
    var body: some View {
        HStack {
            if let albumArt = spotifyManager.albumArtImage {
                Image(nsImage: spotifyManager.isSpotifyRunning ? albumArt : NSApp.applicationIconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: artworkSize,
                           height: artworkSize)
                    .cornerRadius(cornerRadius)
                    .animation(.easeInOut(duration: 0.3), value: artworkSize)
                    .shadow(color: glow && Defaults[.playerGlow] ? (spotifyManager.aveColor.map { Color(nsColor: $0) } ?? .clear).opacity(1) : .clear, radius: 50, x: 5, y: 10)
            }
        }
        .frame(width: size, height: size)
        .onChange(of: spotifyManager.isPlaying) {
            artworkSize = spotifyManager.isPlaying ? size : size - shrink
        }
        .onAppear() {
            artworkSize = spotifyManager.isPlaying ? size : size - shrink
        }
    }
}

#Preview {
    AlbumArtView(size: 80, shrink: 10, cornerRadius: 20, glow: true)
        .padding(60)
}
