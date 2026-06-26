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
    
    @State private var localTrackName: String = ""
    
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
                AlbumArtView(
                    playing: $musicManager.music.isPlaying,
                    size: (NSScreen.main?.isOnNotchScreen ?? false) ? 27.0 : 16.0,
                    shrink: (NSScreen.main?.isOnNotchScreen ?? false) ? 5 : 3,
                    cornerRadius: (NSScreen.main?.isOnNotchScreen ?? false) ? 5.5 : 4,
                    nsImage: musicManager.albumArt ?? NSImage(named: "no_playback")!,
                )
            }) .buttonStyle(ScalingPlainButtonStyle(downScale: 0.85))
                .padding(.leading, 1)
            if notchManager.notchContent == .musicGlance {
                Text(localTrackName)
                    .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                    .lineLimit(1)
                    .padding(.leading, 5)
                    .transition(.scale(scale: 0.2, anchor: .leading).combined(with: .opacity))
                    .frame(minWidth: 75, maxWidth: 125, alignment: .leading)
            }
        }
        .onAppear {
            withAnimation(.bouncy(duration: 0.4)) {
                localTrackName = musicManager.music.trackName
            }
        }
        .onChange(of: musicManager.music.trackName) { _, newValue in
            withAnimation(.bouncy(duration: 0.4)) {
                localTrackName = newValue
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
    
    @State private var localArtistName: String = "Artist"
    
    var body: some View {
        HStack {
            if notchManager.notchContent == .musicGlance {
                Text(localArtistName)
                    .foregroundStyle(Color(musicManager.aveColor ?? .white).gradient)
                    .lineLimit(1)
                    .transition(.scale(scale: 0.2, anchor: .trailing).combined(with: .opacity))
                    .frame(minWidth: 75, maxWidth: 125, alignment: .trailing)
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
        .onAppear {
            withAnimation(.bouncy(duration: 0.4)) {
                localArtistName = musicManager.music.artistName
            }
        }
        .onChange(of: musicManager.music.artistName) { _, newValue in
            withAnimation(.bouncy(duration: 0.4)) {
                localArtistName = newValue
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
        
            //Progress Bar
            HStack (spacing: 14){
                if !musicManager.music.isLive {
                    Text(formatTime(Int(trackPosition)))
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                        .font(.system(size: 12))
                        .monospacedDigit()
                }
                
                ZStack {
                    CustomSlider(
                        value: musicManager.music.isLive ? .constant(0) : $trackPosition,
                        inRange: 0...Double(musicManager.music.trackDuration > 0 ? musicManager.music.trackDuration : 1),
                        activeFillColor: .gray.opacity(0.8),
                        fillColor: musicManager.music.isLive ? Color(NSColor.darkGray).opacity(0.4) : .gray.opacity(0.8),
                        emptyColor: Color(NSColor.darkGray).opacity(0.6),
                        height: 7.0,
                        onEditingChanged: { isEditing in
                            isDragging = isEditing
                            if !isEditing {
                                MusicActions.setProgress(position: trackPosition)
                            }
                        },
                    ) .allowsHitTesting(!musicManager.music.isLive)
                    
                    if musicManager.music.isLive {
                        Text("LIVE")
                            .foregroundStyle(Color(NSColor.darkGray))
                            .fontWeight(.semibold)
                            .font(.system(size: 12))
                            .background {
                                LinearGradient(
                                    stops: [
                                        .init(color: .black.opacity(0), location: 0),
                                        .init(color: .black, location: 0.4),
                                        .init(color: .black, location: 0.6),
                                        .init(color: .black.opacity(0), location: 1),
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: 120, height: 18)
                            }
                    }
                }
                .frame(minWidth: 160, idealWidth: .infinity, maxWidth: .infinity)
                .frame(height: 10)
                
                if !musicManager.music.isLive {
                    Text("-\(formatTime(Int(musicManager.music.trackDuration - trackPosition)))")
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                        .monospacedDigit()
                }
                
            }
            .frame(width: notchManager.notch?.usedStyle == .notch ? 350 : 335, height: 15)
            .padding(.bottom, 3)
            
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
                Task { @MainActor in
                    if musicManager.music.isPlaying == true && trackPosition < musicManager.music.trackDuration {
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
