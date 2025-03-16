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
                
                Image(systemName: "photo")
                    .imageScale(.large)
                Text(SpotifyManager.shared.trackName)
            }
            
            HStack {
            //Shuffle
                Button(action: {
                    spotifyShuffle()
                })
                {

                    Image(systemName: ShuffleIcon)
                            .imageScale(.large)
                            .font(.system(size: 19))
                            .foregroundStyle(.secondary)
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 17)
                
                
            //Skip backward
                Button(action: {
                    spotifyLastTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                        .font(.system(size: 17))
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 5)
                
                
                
            //Pause
                Button(action: {
                    spotifyPlayPause()
                }) {
                    Image(systemName: PlayIcon)
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                        .font(.system(size: 22, weight: .bold))
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 16)
                
                
            //Skip forward
                Button(action: {
                    spotifyNextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                        .font(.system(size: 17))
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 5)
                
            //Speaker
                Image(systemName: deviceIcon)
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 17))
                    .padding(.horizontal, 17)
                
            }
            .padding()
        }
    }
}

#Preview {
    OpendPlayer()
}
