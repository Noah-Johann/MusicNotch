//
//  ButtonView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.04.25.
//

import SwiftUI


struct ButtonView: View {
    
    @State var musicManager = MusicManager.shared
    @ObservedObject var volumeManager = VolumeManager.shared
    
    var body: some View {
        //Controls
        HStack {
            
            //Shuffle
            Button(action: {
                    toggleShuffle()
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
                lastTrack()
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
                playPause()
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
                nextTrack()
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
                if NotchManager.shared.notchContent == .music {
                    NotchManager.shared.setNotchContent(.volume, duration: 0.4)
                } else {
                    NotchManager.shared.setNotchContent(.music, duration: 0.4)
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
