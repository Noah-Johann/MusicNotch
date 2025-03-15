//
//  OpendPlayer.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import SwiftUI
import DynamicNotchKit

struct OpendPlayer: View {
    @ObservedObject var spotifyManager = SpotifyManager.shared
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "airpods.pro")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text(SpotifyManager.shared.trackName)
                Button("play.filled") {
                    
                }
            }
            HStack {
                //Skip backward
                Button(action: {
                    // Deine Aktion hier
                    spotifyPlayPause()
                }) {
                    Image(systemName: "backward.fill")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                }
                
                //Pause
                Button(action: {
                    // Deine Aktion hier
                    spotifyPlayPause()
                }) {
                    Image(systemName: PlayIcon)
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                }
                
                //Skip forward
                Button(action: {
                    // Deine Aktion hier
                    spotifyPlayPause()
                }) {
                    Image(systemName: "forward.fill")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                }
        }
        .padding()
    }
}
}

#Preview {
    OpendPlayer()
}
