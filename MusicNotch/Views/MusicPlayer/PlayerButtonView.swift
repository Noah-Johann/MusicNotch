//
//  PlayerButtonView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.04.25.
//

import SwiftUI
import Defaults


struct PlayerButtonView: View {
    @State var musicManager = MusicManager.shared
    @State var volumeManager = VolumeManager.shared
    @State var gestureManager = GestureManager.shared
    
    var enableSpeaker: Bool = true
    
    @State var forwardArrowName: String = "arrow.clockwise"
    @State var backwardArrowName: String = "arrow.counterclockwise"
    
    var actionItem: MusicActionItem {
        if musicManager.musicPlayer == .nowPlaying {
            return .open
        } else {
            switch Defaults[.musicAction] {
                case .shuffle: return .shuffle
                case .repeating: return .repeating
            }
        }
    }
    
    enum MusicActionItem {
        case shuffle, repeating, open
        
        var iconName: String {
            switch self {
                case .shuffle: return "shuffle"
                case .repeating: return "repeat"
                case .open: return "arrow.up.right"
            }
        }
        
        var iconSize: CGFloat {
            switch self {
                case .open: return 16
                default: return 24
            }
        }
    }
    
        
    var body: some View {
        HStack {
            // MusicAction
            Button {
                if musicManager.musicPlayer == .nowPlaying {
                    openMusicApp()
                } else {
                    switch Defaults[.musicAction] {
                        case .shuffle: MusicActions.toggleShuffle()
                        case .repeating: MusicActions.toggleRepeat()
                    }
                }
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: actionItem.iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary)
                        .frame(width: actionItem.iconSize, height: actionItem.iconSize)
                    if musicManager.musicPlayer != .nowPlaying {
                        if (Defaults[.musicAction] == .repeating && musicManager.music.repeating) || (Defaults[.musicAction] == .shuffle && musicManager.music.shuffle) {
                            Circle()
                                .fill(.secondary)
                                .frame(width: 3, height: 3)
                                .id("DotIndicator")
                        }
                    }
                }
                .frame(height: 35)
                .animation(.smooth(duration: 0.2), value: musicManager.music.repeating)
                .animation(.smooth(duration: 0.2), value: musicManager.music.shuffle)
            } .buttonStyle(ScalingHoverButtonStyle(downScale: 0.8, effectSize: 52))
            
            
            // Backward Skip
            Button {
                if musicManager.music.type == .podcast  {
                    MusicActions.secondsBackwards()
                } else {
                    MusicActions.lastTrack()
                }
            } label: {
                Image(systemName: musicManager.music.type == .podcast ? backwardArrowName : "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(Color.white.opacity(gestureManager.horizontalType == .right ? 1 - (gestureManager.horizontalGestureRelative / 2) : 1))
                    .offset(x: gestureManager.horizontalType == .left ? gestureManager.horizontalGestureRelative * -5 : 0)
                    .scaleEffect(gestureManager.horizontalType == .left ? 1 + (gestureManager.horizontalGestureRelative * 0.1) : 1)
                    .frame(width: 25, height: 25)
            } .buttonStyle(ScalingHoverButtonStyle(downScale: 0.8, effectSize: 52))
            
            
            // PlayPause
            Button { MusicActions.playPause() } label: {
                Image(systemName: musicManager.music.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(Color.white.opacity(1 - (gestureManager.horizontalGestureRelative / 2)))
                    .frame(width: 25, height: 25)
            }
            .buttonStyle(ScalingHoverButtonStyle(downScale: 0.8, effectSize: 52))
            
            
            // Forward Skip
            Button {
                if musicManager.music.type == .podcast  {
                    MusicActions.secondsForwards()
                } else {
                    MusicActions.nextTrack()
                }
            } label: {
                Image(systemName: musicManager.music.type == .podcast ? forwardArrowName : "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(Color.white.opacity(gestureManager.horizontalType == .left ? 1 - (gestureManager.horizontalGestureRelative / 2) : 1))
                    .offset(x: gestureManager.horizontalType == .right ? gestureManager.horizontalGestureRelative * 5 : 0)
                    .scaleEffect(gestureManager.horizontalType == .right ? 1 + (gestureManager.horizontalGestureRelative * 0.1) : 1)
                    .frame(width: 25, height: 25)
            } .buttonStyle(ScalingHoverButtonStyle(downScale: 0.8, effectSize: 52))
            
            
            // Output Device
            Button {
                if NotchManager.shared.notchContent == .music {
                    NotchManager.shared.setNotchContent(.volume, duration: 0.4)
                } else {
                    NotchManager.shared.setNotchContent(.music, duration: 0.4)
                }
            } label: {
                Image(systemName: volumeManager.deviceIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(.secondary)
                    .frame(width: 31, height: 25)
            }
            .buttonStyle(ScalingHoverButtonStyle(downScale: 0.8, effectSize: 52, cornerRadius: 15))
            .disabled(!enableSpeaker)
        }
        .frame(height: 45)
        .animation(.smooth, value: gestureManager.horizontalGestureRelative)
        .task {
            if #available(macOS 15, *) {
                forwardArrowName = "15.arrow.trianglehead.clockwise"
                backwardArrowName = "15.arrow.trianglehead.counterclockwise"
            }
        }
    }
}


#Preview {
    PlayerButtonView()
        .padding()
}
