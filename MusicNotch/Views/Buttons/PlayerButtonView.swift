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
    
    var body: some View {
        HStack {
            HoverEffectButton(
                icon: "shuffle",
                iconColor: .secondary,
                iconSize: 24,
                effectSize: 52,
                cornerRadius: 17,
                dot: $musicManager.music.shuffle
            ) {
                MusicActions.toggleShuffle()
            } .opacity(musicManager.musicPlayer == .nowPlaying ? 0 : 1)
            
            HoverEffectButton(
                icon: musicManager.music.type == .podcast ? "15.arrow.trianglehead.counterclockwise" : "backward.fill",
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
                icon: musicManager.music.type == .podcast ? "15.arrow.trianglehead.clockwise" : "forward.fill",
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
        .frame(height: 43)
    }
}

#Preview {
    PlayerButtonView()
        .padding()
}
