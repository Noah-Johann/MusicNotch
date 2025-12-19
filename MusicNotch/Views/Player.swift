//
//  OpendPlayer.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import SwiftUI
import DynamicNotchKit
import Defaults
import AppKit

struct Player: View {
    @ObservedObject var spotifyManager = SpotifyManager.shared
    @ObservedObject var musicManager = MusicManager.shared
    @ObservedObject var accessibilityManager = AccessibilityManager.shared
    
    @State private var isDragging = false
    @State private var trackposition : Double = 0
    @State private var playbackTimer: Timer?
    
    @Default(.coloredSpect) private var coloredSpect
    @Default(.bottomGadgets) private var bottomGadgets
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    AlbumArtView(size: 80, shrink: 10, cornerRadius: 17, glow: true)

                    
                    Button(action: {
                        let url = URL(fileURLWithPath: "/Applications/Spotify.app")
                        NSWorkspace.shared.open(url)
                    }, label: {
                        Color.clear
                            .frame(width: 80, height: 80)
                            .contentShape(Rectangle())
                    }) .buttonStyle(.plain)
                        .frame(width: 80, height : 80)
                }
                VStack {
                    Text(spotifyManager.isSpotifyRunning ? musicManager.music.trackName : "Nothing playing")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 240, alignment: .leading)
                    Text(spotifyManager.isSpotifyRunning ? musicManager.music.artistName : "Start a song on Spotify")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.gray)
                        .frame(width: 240, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .padding(.top, 27)
                
                if !accessibilityManager.isReduceMotion {
                    Rectangle()
                        .fill(coloredSpect ? Color(nsColor: musicManager.music.aveColor ?? .white).gradient : Color.white.gradient)
                        .frame(width: 35, alignment: .center)
                        .mask {
                            AudioSpectrumView(isPlaying: $musicManager.music.isPlaying)
                                .frame(width: 20, height: 20)
                        }
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 35)
                }
                
            } .frame(width: 300)
                .padding(.bottom, 8)
        
            //Progress Bar
            HStack {
                Text(formatTime(Int(trackposition)))
                    .frame(minWidth: 50, maxWidth: 80, minHeight: 20, alignment: .center)
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
                
                CustomSlider(value: $trackposition,
                             inRange: 0...Double(musicManager.music.trackDuration),
                             activeFillColor: .white,
                             fillColor: .white,
                             emptyColor: Color(NSColor.darkGray),
                             height: 8.0,
                             onEditingChanged: { isEditing in
                    isDragging = isEditing
                    if !isEditing {
                        progressChanged()
                    }
                }) .frame(width: 280, height: 10, alignment: .center)
                
                Text("-\(formatTime(musicManager.music.trackDuration - Int(trackposition)))")
                    .frame(minWidth: 55, maxWidth: 80, minHeight: 20, alignment: .center)
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
            }.frame(height: 15)
                .padding(.bottom, 6)
            
            ButtonView()
            
        }
        .background(.black)
        .onChange(of: musicManager.music.trackPosition) { _, newValue in
            trackposition = Double(newValue)
        }
        .onAppear {
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task { @MainActor in
                    if musicManager.music.isPlaying == true {
                        trackposition += 1
                    }
                }
            }
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }

        .padding(.bottom, bottomGadgets ? 4 : 15)
        .padding(.top, 10)
        .contextMenu {
            ContextMenuView()
        }
    }
    
    private func progressChanged() {
        //print("new value: \(trackposition)")
        let script = """
        tell application "Spotify"
            set player position to \(trackposition)
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var errorDict: NSDictionary?
        appleScript?.executeAndReturnError(&errorDict)
        
        if let error = errorDict {
            print("AppleScript Error: \(error)")
        }
    }
}

#Preview {
    Player()
}

    
