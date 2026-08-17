//
//  MusicViewTrailing.swift
//  MusicNotch
//
//  Created by Noah Johann on 17.08.26.
//

import SwiftUI
import Defaults

struct MusicViewTrailing: View {
    @State private var notchManager = NotchManager.shared
    @State private var musicManager = MusicManager.shared
    @State private var gestureManager = GestureManager.shared
    @State var accessibilityManager = AccessibilityManager.shared
    
    @Default(.coloredSpect) private var coloredSpect
    @Default(.hoverBehavior) private var hoverBehavior
    
    @State private var isHovering: Bool = false
    
    @State private var contentWidth: CGFloat = 30
    @State private var frameWidthAnimated: CGFloat = 0
    
    var skipIconOffset: CGFloat {
        var offset: CGFloat = 0
        if let notchScreen = NSScreen.main?.isOnNotchScreen, notchScreen == true {
            offset = 15
        } else {
            offset = 4
        }
        if notchManager.notchContent == .musicGlance {
            offset += 120
        }
        if gestureManager.horizontalType == .right {
            offset += gestureManager.horizontalGestureRelative * 23
        }
        return offset
    }
    
    var audioSpectrumOffset: CGFloat {
        if notchManager.notchContent == .musicGlance {
            return 120
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
            width += 20
        }
        if gestureManager.horizontalType == .right {
            width += gestureManager.horizontalGestureRelative * 27
        }

        return width
    }
    
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "forward.end.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.white.opacity(gestureManager.horizontalGestureRelative))
                .frame(width: 12, height: 12)
                .scaleEffect(gestureManager.horizontalType == .right ? gestureManager.horizontalGestureRelative : 0, anchor: .trailing)
                .blur(radius: 5 - gestureManager.horizontalGestureRelative * 5)
                .offset(x: skipIconOffset)
            
            Button {
                MusicActions.playPause()
            } label: {
                ZStack {
                    if !accessibilityManager.isReduceMotion {
                        Rectangle()
                            .fill(coloredSpect ? Color(nsColor: musicManager.aveColor ?? .white).gradient : Color.white.gradient)
                            .padding(.trailing, 3)
                            .frame(width: (NSScreen.main?.isOnNotchScreen ?? false) ? 30 : 20, alignment: .center)
                            .mask {
                                AudioSpectrumView(isPlaying: $musicManager.music.isPlaying)
                                    .frame(width: (NSScreen.main?.isOnNotchScreen ?? false) ? 15 : 9, height: (NSScreen.main?.isOnNotchScreen ?? false) ? 15 : 12)
                            }
                        .blur(radius: isHovering ? 1.7 : 0)
                    }
                    
                    if isHovering || accessibilityManager.isReduceMotion {
                        Image(systemName: musicManager.music.isPlaying == true ? "pause.fill" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
                    }
                } .frame(width: (NSScreen.main?.isOnNotchScreen ?? false) ? 30 : 20, height: (NSScreen.main?.isOnNotchScreen ?? false) ? 30 : 20)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                if hovering {
                    guard hoverBehavior == .disabled else { isHovering = false ; return}
                    isHovering = true
                } else {
                    isHovering = false
                }
            }
            .offset(x: audioSpectrumOffset)
            
            Text(musicManager.music.artistName)
                .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                .lineLimit(1)
                .scaleEffect(notchManager.notchContent == .musicGlance ? 1 : 0)
                .frame(width: 115, alignment: .trailing)
                .offset(x: textOffset)
        }
        .frame(width: frameWidthAnimated, alignment: .leading)
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
        .animation(.smooth(duration: 0.4), value: audioSpectrumOffset)
        .animation(.smooth(duration: 0.4), value: textOffset)
    }
}
