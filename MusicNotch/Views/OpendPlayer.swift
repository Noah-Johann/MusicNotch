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
                Image(systemName: deviceIcon)
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
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())

                
                //Pause
                Button(action: {
                    // Deine Aktion hier
                    spotifyPlayPause()
                }) {
                    Image(systemName: PlayIcon)
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                        .font(.system(size: 17, weight: .bold))
                        .padding(.horizontal, 9)

                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())

                
                //Skip forward
                Button(action: {
                    // Deine Aktion hier
                    spotifyPlayPause()
                }) {
                    Image(systemName: "forward.fill")
                        .imageScale(.large)
                        .foregroundStyle(.primary)

                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())

        }
        .padding()
    }
}
}

#Preview {
    OpendPlayer()
}
