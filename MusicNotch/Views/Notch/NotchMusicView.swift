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
    
    @Default(.coloredSpect) private var coloredSpect
    
    var body: some View {
        VStack (spacing: 12) {
            HStack {
                ZStack {
                    AlbumArtView(size: 65, shrink: 10, cornerRadius: 12, glow: true)

                    
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
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 220, alignment: .leading)
                    Text(musicManager.music.artistName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.gray)
                        .frame(width: 220, alignment: .leading)
                }
                .lineLimit(1)
                .padding(.leading, 8)
                .padding(.top, 27)
                
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
                
            } .frame(width: 350)
                .padding(.bottom, 8)
        
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
                    activeFillColor: .white,
                    fillColor: .white,
                    emptyColor: Color(NSColor.darkGray),
                    height: 8.0,
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
                
            }.frame(width: 350, height: 15)
                .padding(.bottom, 6)
            
            PlayerButtonView()
            
        }
        .background(.black)
        .onChange(of: musicManager.music.trackPosition) { _, newValue in
            trackPosition = Double(newValue)
        }
        .onAppear {
            trackPosition = Double(musicManager.music.trackPosition)
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                print("playback timer")
                Task { @MainActor in
                    if musicManager.music.isPlaying == true {
                        trackPosition += 1
                    }
                }
            }
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }

        .padding(.bottom, 10)
        .padding(.top, 15)
        .contextMenu {
            ContextMenuView()
        }
    }
}

#Preview {
    NotchMusicViewTrailing()
        .frame(width: 100, height: 100)
}


