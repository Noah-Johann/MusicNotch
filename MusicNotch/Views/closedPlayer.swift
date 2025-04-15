//
//  OpendPlayer.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import SwiftUI
import DynamicNotchKit
import AppKit
import Defaults


struct closedPlayer: View {
    @State public var albumArtSizeClosed = 30.0
    @Default(.notchSizeChange) private var notchSizeChange

    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    
                    if let albumArt = spotifyManager.albumArtImage {
                        Image(nsImage: albumArt)
                            .resizable()
                            .scaledToFit()
                            .frame(width: albumArtSizeClosed, height: albumArtSizeClosed)
                            .cornerRadius(6)
                            .animation(.easeInOut(duration: 0.3), value: albumArtSizeClosed)
                        
                    }
                }   .frame(width: 30, height: 30)
                    .padding(.leading, 3)
                    .padding(.trailing, 230)
                
                AudioSpectrumView(isPlaying: spotifyManager.isPlaying)
                    .foregroundColor(.white)
                    .frame(width: 15, height: 15)
                
            } .frame(width: 284, height: notchHeight + notchSizeChange, alignment: .center)
            
        }
        .onChange(of: spotifyManager.isPlaying) {
            changeArtSize(spotifyManager.isPlaying)
        }
    }
    
    func changeArtSize (_ playbackState: Bool) {
        if playbackState == true {
            albumArtSizeClosed = 30.0
        } else if playbackState == false {
            albumArtSizeClosed = 25.0
        }
    }
}

#Preview {
    closedPlayer()
}
