//
//  AudioSpectView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI
import Defaults

struct AudioSpectView: View {
    @ObservedObject var spotifyManager = SpotifyManager.shared
    @ObservedObject var musicManager = MusicManager.shared
    @ObservedObject var accessibilityManager = AccessibilityManager.shared
    
    @Default(.coloredSpect) private var coloredSpect
    @Default(.openNotchOnHover) private var openNotchOnHover
    
    @State private var hovering: Bool = false
    
    var body: some View {
        ZStack {
            if hovering || accessibilityManager.isReduceMotion {
                Button {
                    spotifyPlayPause()
                } label: {
                    Image(systemName: musicManager.music.isPlaying == true ? "pause.fill" : "play.fill")
                        .contentTransition(.symbolEffect(.replace))
                } .buttonStyle(PlainButtonStyle())
            }
            
            if !hovering && !accessibilityManager.isReduceMotion {
                Rectangle()
                    .fill(coloredSpect ? Color(nsColor: musicManager.music.aveColor ?? .white).gradient : Color.white.gradient)
                    .frame(width: 35, alignment: .center)
                    .mask {
                        AudioSpectrumView(isPlaying: $musicManager.music.isPlaying)
                            .frame(width: 15, height: 16)
                    }
            }
        } .onHover(perform: { isHovering in
            if isHovering {
                guard !openNotchOnHover else { hovering = false ; return}
                
                hovering = true
            } else {
                hovering = false
            }
        })
        .animation(.bouncy(duration: 0.4), value: hovering)
        .frame(width: 30, height: 30)
    }
    
}

#Preview {
    AudioSpectView()
}
