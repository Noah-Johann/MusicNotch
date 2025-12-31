//
//  AudioSpectView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI
import Defaults

struct AudioSpectView: View {
    @State var musicManager = MusicManager.shared
    @ObservedObject var accessibilityManager = AccessibilityManager.shared
    
    @Default(.coloredSpect) private var coloredSpect
    @Default(.hoverBehavior) private var hoverBehavior
    
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
                    .fill(coloredSpect ? Color(nsColor: musicManager.aveColor ?? .white).gradient : Color.white.gradient)
                    .frame(width: 35, alignment: .center)
                    .mask {
                        AudioSpectrumView(isPlaying: $musicManager.music.isPlaying)
                            .frame(width: 15, height: 16)
                    }
            }
        } .onHover(perform: { isHovering in
            if isHovering {
                guard hoverBehavior == .disabled else { hovering = false ; return}
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
