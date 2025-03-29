//
//  OpendPlayer.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import SwiftUI
import DynamicNotchKit
import AppKit


struct closedPlayer: View {
    static let shared = closedPlayer()

    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    var body: some View {
        VStack {
            HStack {
                
                if let albumArt = spotifyManager.albumArtImage {
                    Image(nsImage: albumArt)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .cornerRadius(6)
                        .padding(.leading, 3)
                        .padding(.trailing, 230)
                }
                AudioSpectrumView(isPlaying: spotifyManager.isPlaying)
                    .foregroundColor(.white)
                    .frame(width: 15, height: 15)
                
            } .frame(width: 284, height: notchHeight + notchSizeChange, alignment: .center)
            
        }
    }
}

#Preview {
    closedPlayer()
}
