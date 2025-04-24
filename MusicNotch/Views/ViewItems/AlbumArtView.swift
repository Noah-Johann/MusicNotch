//
//  AlbumArtView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI
import Defaults

struct AlbumArtView: View {
    
    var sizeState: String
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @State private var albumArtSizeOpen = 80.0
    @State public var albumArtSizeClosed = Defaults[.notchDisplay] ? 30.0 : 20.0
    
    var body: some View {
        HStack {
            if let albumArt = spotifyManager.albumArtImage {
                Image(nsImage: albumArt)
                    .resizable()
                    .scaledToFit()
                    .frame(width: sizeState == "open" ? albumArtSizeOpen : albumArtSizeClosed,
                           height: sizeState == "open" ? albumArtSizeOpen : albumArtSizeClosed)
                    .cornerRadius(Defaults[.notchDisplay] ? 6 : 4)
                    .padding(.vertical, 10)
                    .animation(.easeInOut(duration: 0.3))
                
            }
        }
        .frame(width: sizeState == "open" ? 80 : 30,
               height: sizeState == "open" ? 80 : 30)
        .padding(.leading, sizeState == "closed" ? 3 : 0)
        .animation(.easeInOut, value: 0.3)
        .onChange(of: spotifyManager.isPlaying) {
            changeArtSize(spotifyManager.isPlaying)
        }
        .onAppear() {
            changeArtSize(spotifyManager.isPlaying)
        }
    }
    
    func changeArtSize (_ playbackState: Bool) {
        if playbackState == true {
            albumArtSizeOpen = 80
            albumArtSizeClosed = Defaults[.notchDisplay] ? 30.0 : 20.0
            
        } else if playbackState == false {
            albumArtSizeOpen = 70
            albumArtSizeClosed = Defaults[.notchDisplay] ? 25 : 15
        }
    }

}

#Preview {
    AlbumArtView(sizeState: "open")
}
