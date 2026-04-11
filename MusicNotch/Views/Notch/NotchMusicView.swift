//
//  NotchMusicView.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.11.25.
//

import SwiftUI
import Defaults

struct NotchMusicViewLeading: View {
    @State private var notchManager = NotchManager.shared
    @State private var musicManager = MusicManager.shared
    
    var body: some View {
        HStack {
            Button (action: {
                if notchManager.notchContent == .music {
                    NotchManager.shared.setNotchContent(.musicGlance)
                } else if notchManager.notchContent == .musicGlance {
                    NotchManager.shared.setNotchContent(.music)
                } else {
                    return
                }
            }, label: {
                AlbumArtView(size: (NSScreen.main?.isOnNotchScreen ?? false) ? 30.0 : 20.0,
                             shrink: 5,
                             cornerRadius: (NSScreen.main?.isOnNotchScreen ?? false) ? 6 : 4,
                             glow: false,
                )
            }) .buttonStyle(.plain)
                .padding(.leading, 3)
            if notchManager.notchContent == .musicGlance {
                Text(musicManager.music.trackName)
                    .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                    .frame(minWidth: 75, maxWidth: 125)
            }
        }
    }
}

struct NotchMusicViewTrailing: View {
    @State private var notchManager = NotchManager.shared
    @State private var musicManager = MusicManager.shared
    @State var accessibilityManager = AccessibilityManager.shared
    
    @Default(.coloredSpect) private var coloredSpect
    @Default(.hoverBehavior) private var hoverBehavior
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack {
            if notchManager.notchContent == .musicGlance {
                Text(musicManager.music.artistName)
                    .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                    .frame(minWidth: 75, maxWidth: 125)
            }
            
            Button {
                MusicActions.playPause()
            } label: {
                ZStack {
                    if !accessibilityManager.isReduceMotion {
                        Rectangle()
                            .fill(coloredSpect ? Color(nsColor: musicManager.aveColor ?? .white).gradient : Color.white.gradient)
                            .frame(width: 30, alignment: .center)
                            .mask {
                                AudioSpectrumView(isPlaying: $musicManager.music.isPlaying)
                                    .frame(width: 15, height: 15)
                            }
                        .blur(radius: isHovering ? 1.7 : 0)
                    }
                    
                    if isHovering || accessibilityManager.isReduceMotion {
                        Image(systemName: musicManager.music.isPlaying == true ? "pause.fill" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
                    }
                } .frame(width: 30, height: 30)
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
        }
    }
}

struct NotchMusicViewExpanded: View {
    @State var musicManager = MusicManager.shared
    @State var accessibilityManager = AccessibilityManager.shared
    
    @State private var isDragging = false
    @State private var playbackTimer: Timer?
    
    @State private var trackPosition: Double = 0
    
    @Environment(NotchManager.self) private var notchManager
    
    @Default(.coloredSpect) private var coloredSpect
    
    var body: some View {
        VStack (spacing: 12) {
            HStack {
                ZStack {
                    AlbumArtView(size: 65, shrink: 10, cornerRadius: notchManager.notch?.usedStyle == .notch ? 12 : 10, glow: true)
                    
                    Button(action: {
                        openMusicApp()
                    }, label: {
                        Color.clear
                            .frame(width: 65, height: 65)
                            .contentShape(Rectangle())
                    }) .buttonStyle(.plain)
                        .frame(width: 65, height : 65)
                }
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
        
            //Progress Bar
            HStack (spacing: 14){
                Text(formatTime(Int(trackPosition)))
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
                    .monospacedDigit()
                
                CustomSlider(
                    value: $trackPosition,
                    inRange: 0...Double(musicManager.music.trackDuration),
                    activeFillColor: .gray.opacity(0.8),
                    fillColor: .gray.opacity(0.8),
                    emptyColor: Color(NSColor.darkGray).opacity(0.6),
                    height: 7.0,
                    onEditingChanged: { isEditing in
                        isDragging = isEditing
                        if !isEditing {
                            MusicActions.setProgress(position: trackPosition)
                        }
                    },
                ) .frame(minWidth: 160, idealWidth: .infinity, maxWidth: .infinity)
                
                Text("-\(formatTime(musicManager.music.trackDuration - Int(trackPosition)))")
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                    .monospacedDigit()
                
            }
            .frame(width: notchManager.notch?.usedStyle == .notch ? 350 : 335, height: 15)
            .padding(.bottom, 9)
            
            PlayerButtonView()
            
        }
        .background(.black)
        .onChange(of: musicManager.music.trackPosition) { _, newValue in
            if musicManager.music.trackPosition > musicManager.music.trackDuration {
                trackPosition = Double(musicManager.music.trackDuration)
            } else {
                trackPosition = Double(musicManager.music.trackPosition)
            }
        }
        .onAppear {
            if musicManager.music.trackPosition > musicManager.music.trackDuration {
                trackPosition = Double(musicManager.music.trackDuration)
            } else {
                trackPosition = Double(musicManager.music.trackPosition)
            }
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                print("playback timer")
                Task { @MainActor in
                    if musicManager.music.isPlaying == true && Int(trackPosition) < musicManager.music.trackDuration {
                        trackPosition += 1
                    }
                }
            }
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }
        .contextMenu {
            ContextMenuView()
        }
    }
}

#Preview(traits: .defaultLayout) {
    NotchMusicViewExpanded()
        .frame(height: 197)
}


