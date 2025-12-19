//
//  ButtonView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.04.25.
//

import SwiftUI


struct ButtonView: View {
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    @ObservedObject var musicManager = MusicManager.shared
    @ObservedObject var volumeManager = VolumeManager.shared
    
    var body: some View {
        //Controls
        HStack {
            
            //Shuffle
            Button(action: {
                    spotifyShuffle()
            })
            {
                VStack (spacing: 3){
                    Image(systemName: "shuffle")
                        .imageScale(.large)
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 20, height: 20)
                    if musicManager.music.shuffle {
                        Circle()
                            .fill(Color.secondary)
                            .frame(width: 3, height: 3)
                    }
                }            .transition(.opacity.combined(with: .scale))
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: musicManager.music.shuffle)
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
                Image(systemName: musicManager.music.isPlaying ? "pause.fill" : "play.fill")
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
            Button(action: {
                if NotchContentState.shared.notchContent == .music {
                    withAnimation(.bouncy(duration: 0.6)) {
                        NotchContentState.shared.notchContent = .volume
                    }
                } else {
                    withAnimation(.bouncy(duration: 0.6)) {
                        NotchContentState.shared.notchContent = .music
                    }
                }
            }) {
                Image(systemName: volumeManager.deviceIcon)
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 17))
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 17)
            }
            .buttonStyle(PlainButtonStyle())
        } .frame(height: 40)
    }
}

#Preview {
    ButtonView()
        .padding()
}
