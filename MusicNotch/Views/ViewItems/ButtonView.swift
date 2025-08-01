//
//  ButtonView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.04.25.
//

import SwiftUI

@MainActor
struct ButtonView: View {
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    var body: some View {
        //Controls
        HStack {
            
            //Shuffle
            Button(action: {
                spotifyShuffle()
            })
            {
                
                Image(systemName: spotifyManager.shuffle ? "shuffle.circle.fill" : "shuffle.circle")
                    .imageScale(.large)
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                
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
                    .frame(width: 30, height: 30)
                
            }
            .background(Color.clear)
            .buttonStyle(BorderlessButtonStyle())
            .padding(.horizontal, 5)
            
            
            
            //Pause
            Button(action: {
                spotifyPlayPause()
            }) {
                Image(systemName: spotifyManager.isPlaying ? "pause.fill" : "play.fill")
                    .imageScale(.large)
                    .foregroundStyle(.primary)
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 30, height: 30)
                    .contentTransition(.symbolEffect(.replace))
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
                    .frame(width: 30, height: 30)
                
            }
            .background(Color.clear)
            .buttonStyle(BorderlessButtonStyle())
            .padding(.horizontal, 5)
            
            
            //Speaker
            Image(systemName: AudioDeviceManager.shared.deviceIcon)
                .imageScale(.large)
                .foregroundStyle(.secondary)
                .font(.system(size: 17))
                .frame(width: 30, height: 30)
                .padding(.horizontal, 17)
            
        }
    }
}

#Preview {
    ButtonView()
}
