//
//  NotchMusicView.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.11.25.
//

import SwiftUI
import Defaults

struct NotchMusicViewLeading: View {
    var body: some View {
        MusicViewLeading()
    }
}

struct NotchMusicViewTrailing: View {
    var body: some View {
        MusicViewTrailing()
    }
}

struct NotchMusicViewExpanded: View {
    @State var musicManager = MusicManager.shared
    @State var accessibilityManager = AccessibilityManager.shared    
    
    @Environment(NotchManager.self) private var notchManager
    
    @Default(.coloredSpect) private var coloredSpect
    @Default(.coloredProgressBar) private var coloredProgressBar
    
    var body: some View {
        VStack (spacing: 12) {
            HStack {
                Button {
                    openMusicApp()
                } label: {
                    AlbumArtView(playing: $musicManager.music.isPlaying, size: 65, shrink: 10, cornerRadius: 12, nsImage: musicManager.albumArt ?? NSImage(named: "no_playback")!)
                }
                .frame(width: 65, height: 65)
                .buttonStyle(ScalingPlainButtonStyle(downScale: 0.85))
                
                VStack {
                    Text(musicManager.music.trackName)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(width: notchManager.notch?.usedStyle == .notch ? 220 : 200, alignment: .leading)
                    Text(musicManager.music.artistName)
                        .fontWeight(.light)
                        .foregroundStyle(.gray)
                        .frame(width: notchManager.notch?.usedStyle == .notch ? 220 : 200, alignment: .leading)
                }
                .lineLimit(1)
                .padding(.leading, 11)
                .padding(.top, notchManager.notch?.usedStyle == .notch ? 18 : 0)
                
                Spacer()
                
                if !accessibilityManager.isReduceMotion {
                    Rectangle()
                        .fill(coloredSpect ? Color(nsColor: musicManager.aveColor ?? .white).gradient : Color.white.gradient)
                        .frame(width: 30, alignment: .center)
                        .mask {
                            AudioSpectrumView(isPlaying: $musicManager.music.isPlaying)
                                .frame(width: 15, height: 15)
                        }
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 35)
                }
                
            }
            .frame(width: notchManager.notch?.usedStyle == .notch ? 350 : 335)
            .frame(height: 65, alignment: .center)
            .padding(.bottom, 4)
        
            MusicProgressBarView(
                width: notchManager.notch?.usedStyle == .notch ? 350 : 335,
                coloredProgressBar: coloredProgressBar
            )
            
            PlayerButtonView()
            
        }
        .background(.black)
        .contextMenu {
            ContextMenuView()
        }
    }
}

#Preview(traits: .defaultLayout) {
    NotchMusicViewExpanded()
        .frame(height: 197)
}
