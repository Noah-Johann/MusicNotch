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
    
    @State var musicManager = MusicManager.shared

    @State private var artworkSize: Double = 0
    
    var body: some View {
        HStack {
            if let albumArt = musicManager.albumArt {
                Image(nsImage: albumArt)
                    .resizable()
                    .scaledToFit()
                    .frame(width: artworkSize,
                           height: artworkSize)
                    .cornerRadius(cornerRadius)
                    .animation(.easeInOut(duration: 0.3), value: artworkSize)
            }
        }
        .frame(width: size, height: size)
        .onChange(of: musicManager.music.isPlaying) {
            artworkSize = musicManager.music.isPlaying ? size : size - shrink
        }
        .onAppear() {
            artworkSize = musicManager.music.isPlaying ? size : size - shrink
        }
    }
}

#Preview {
    AlbumArtView(size: 80, shrink: 10, cornerRadius: 20)
        .padding(60)
}
