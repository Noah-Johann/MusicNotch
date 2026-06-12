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
    
    var enableSpeaker: Bool = true
    
    @State var forwardArrowName: String = "arrow.clockwise"
    @State var backwardArrowName: String = "arrow.counterclockwise"
    
    var actionIcon: String {
        if musicManager.musicPlayer == .nowPlaying {
            return "arrow.up.right"
        } else {
            switch Defaults[.musicAction] {
                case .shuffle: return "shuffle"
                case .repeating: return musicManager.music.repeating == .one ? "repeat.1" : "repeat"
            }
        }
    }
    
        
    var body: some View {
        HStack {
            HoverEffectButton(
                icon: actionIcon,
                iconColor: .secondary,
                iconSize: musicManager.musicPlayer == .nowPlaying ? 17 : 24,
                effectSize: 52,
                cornerRadius: 17,
                dot: musicManager.musicPlayer == .nowPlaying ? .constant(false) : Binding(
                    get: {
                        switch Defaults[.musicAction] {
                            case .shuffle: return musicManager.music.shuffle
                            case .repeating: return musicManager.music.repeating != .off
                        }
                    },
                    set: { _ = $0 }
                )
            ) {
                if musicManager.musicPlayer == .nowPlaying {
                    openMusicApp()
                } else {
                    switch Defaults[.musicAction] {
                        case .shuffle: MusicActions.toggleShuffle()
                        case .repeating: MusicActions.toggleRepeat()
                    }
                }
            }
            
            HoverEffectButton(
                icon: musicManager.music.type == .podcast ? backwardArrowName : "backward.fill",
                iconSize: 25,
                effectSize: 52,
                cornerRadius: 17,
                dot: .constant(false)
            ) {
                if musicManager.music.type == .podcast {
                    MusicActions.secondsBackwards()
                } else {
                    MusicActions.lastTrack()
                }
            }
            
            HoverEffectButton(
                icon: musicManager.music.isPlaying ? "pause.fill" : "play.fill",
                iconSize: 25,
                effectSize: 52,
                cornerRadius: 17,
                dot: .constant(false)
            ) {
                MusicActions.playPause()
            }
            
            HoverEffectButton(
                icon: musicManager.music.type == .podcast ? forwardArrowName : "forward.fill",
                iconSize: 25,
                effectSize: 52,
                cornerRadius: 17,
                dot: .constant(false)
            ) {
                if musicManager.music.type == .podcast  {
                    MusicActions.secondsForwards()
                } else {
                    MusicActions.nextTrack()
                }
            }
            
            HoverEffectButton(
                icon: volumeManager.deviceIcon,
                iconColor: .secondary, iconSize: 30,
                effectSize: 52,
                cornerRadius: 15,
                dot: .constant(false)
            ) {
                if NotchManager.shared.notchContent == .music {
                    NotchManager.shared.setNotchContent(.volume, duration: 0.4)
                } else {
                    NotchManager.shared.setNotchContent(.music, duration: 0.4)
                }
            } .disabled(!enableSpeaker)
        }
        .frame(height: 45)
        .onAppear {
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
