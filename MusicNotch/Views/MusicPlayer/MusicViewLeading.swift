//
//  MusicViewLeading.swift
//  MusicNotch
//
//  Created by Noah Johann on 17.08.26.
//

import SwiftUI

struct MusicViewLeading: View {
    @State private var notchManager = NotchManager.shared
    @State private var musicManager = MusicManager.shared
    @State private var gestureManager = GestureManager.shared
    
    @State private var contentWidth: CGFloat = 30
    @State private var frameWidthAnimated: CGFloat = 0
    
    var skipIconOffset: CGFloat {
        var offset: CGFloat = 0
        if let notchScreen = NSScreen.main?.isOnNotchScreen, notchScreen == true {
            offset = -15
        } else {
            offset = -2
        }
        if notchManager.notchContent == .musicGlance {
            offset -= 120
        }
        if gestureManager.horizontalType == .left {
            offset -= gestureManager.horizontalGestureRelative * 23
        }
        return offset
    }
    
    var albumArtOffset: CGFloat {
        if notchManager.notchContent == .musicGlance {
            return -120
        } else {
            return 0
        }
    }
    
    var textOffset: CGFloat {
        if notchManager.notchContent == .musicGlance {
            return 0
        } else {
            return 120
        }
    }
    
    var frameWidth: CGFloat {
        var width: CGFloat = 0
        if notchManager.notchContent == .musicGlance {
            width = 120
        }
        if let notchScreen = NSScreen.main?.isOnNotchScreen, notchScreen == true {
            width += 28
        } else {
            width += 18
        }
        
        if gestureManager.horizontalType == .left {
            width += gestureManager.horizontalGestureRelative * 27
        }

        return width
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Image(systemName: "backward.end.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.white.opacity(gestureManager.horizontalGestureRelative))
                .frame(width: 12, height: 12)
                .scaleEffect(gestureManager.horizontalType == .left ? gestureManager.horizontalGestureRelative : 0, anchor: .trailing)
                .blur(radius: 5 - gestureManager.horizontalGestureRelative * 5)
                .offset(x: skipIconOffset)
            
            Button {
                if notchManager.notchContent == .music {
                    NotchManager.shared.setNotchContent(.musicGlance)
                } else if notchManager.notchContent == .musicGlance {
                    NotchManager.shared.setNotchContent(.music)
                } else {
                    return
                }
            } label: {
                AlbumArtView(
                    playing: $musicManager.music.isPlaying,
                    size: (NSScreen.main?.isOnNotchScreen ?? false) ? 25.0 : 16.0,
                    shrink: (NSScreen.main?.isOnNotchScreen ?? false) ? 5 : 3,
                    cornerRadius: (NSScreen.main?.isOnNotchScreen ?? false) ? 5.5 : 4,
                    nsImage: musicManager.albumArt ?? NSImage(named: "no_playback")!,
                )
            }
            .buttonStyle(ScalingPlainButtonStyle(downScale: 0.85))
            .offset(x: albumArtOffset)
            
            
            Text(musicManager.music.trackName)
                .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                .lineLimit(1)
                .padding(.leading, 4)
                .scaleEffect(notchManager.notchContent == .musicGlance ? 1 : 0)
                .frame(width: 115, alignment: .leading)
                .offset(x: textOffset)
        }
        .frame(width: frameWidthAnimated, alignment: .trailing)
        .onAppear {
            withAnimation(.smooth(duration: 0.4)) {
                frameWidthAnimated = frameWidth
            }
        }
        .onChange(of: frameWidth) { _, new in
            withAnimation(.smooth(duration: 0.4)) {
                frameWidthAnimated = new
            }
        }
        .animation(.smooth(duration: 0.4), value: skipIconOffset)
        .animation(.smooth(duration: 0.4), value: albumArtOffset)
        .animation(.smooth(duration: 0.4), value: textOffset)
    }
}
