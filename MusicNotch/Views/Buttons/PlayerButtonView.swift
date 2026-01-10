//
//  PlayerButtonView.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.04.25.
//

import SwiftUI


struct PlayerButtonView: View {
    @State var musicManager = MusicManager.shared
    @ObservedObject var volumeManager = VolumeManager.shared
    
    var enableSpeaker: Bool = true
    
    var body: some View {
        HStack {
            HoverEffectButton(icon: "shuffle", iconColor: .secondary, iconSize: 24, effectSize: 52, cornerRadius: 17, dot: $musicManager.music.shuffle) {
                MusicActions.toggleShuffle()
            }
            
            
            HoverEffectButton(icon: "backward.fill", iconSize: 25, effectSize: 52, cornerRadius: 17, dot: .constant(false)) {
                MusicActions.lastTrack()
            }
            
            
            HoverEffectButton(icon: musicManager.music.isPlaying ? "pause.fill" : "play.fill", iconSize: 25, effectSize: 52, cornerRadius: 17, dot: .constant(false)) {
                MusicActions.playPause()
            }
            
            
            HoverEffectButton(icon: "forward.fill", iconSize: 25, effectSize: 52, cornerRadius: 17, dot: .constant(false)) {
                MusicActions.nextTrack()
            }
            
            HoverEffectButton(icon: volumeManager.deviceIcon, iconColor: .secondary, iconSize: 30, effectSize: 52, cornerRadius: 15, dot: .constant(false)) {
                if NotchManager.shared.notchContent == .music {
                    NotchManager.shared.setNotchContent(.volume, duration: 0.4)
                } else {
                    NotchManager.shared.setNotchContent(.music, duration: 0.4)
                }
            } .disabled(!enableSpeaker)
        } .frame(height: 45)
    }
}

#Preview {
    PlayerButtonView()
        .padding()
}
