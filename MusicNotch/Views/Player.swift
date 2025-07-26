//
//  OpendPlayer.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import SwiftUI
import DynamicNotchKit
import Defaults

struct Player: View {
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @State private var isDragging = false
    @State private var trackposition : Double = 0
    @State private var playbackTimer: Timer?
    
    @Default(.coloredSpect) private var coloredSpect
    
    var body: some View {
        VStack {
            HStack {
                AlbumArtView(sizeState: "open")
                
                VStack {
                    Text(spotifyManager.trackName)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 240, alignment: .leading)
                    Text(spotifyManager.artistName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.gray)
                        .frame(width: 240, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .padding(.top, 27)
                
                Rectangle()
                    .fill(coloredSpect ? Color(nsColor: spotifyManager.aveColor ?? .white).gradient : Color.white.gradient)
                    .frame(width: 35, alignment: .center)
                    .mask {
                        AudioSpectrumView(isPlaying: $spotifyManager.isPlaying)
                            .frame(width: 20, height: 20)
                    }
                
                
            } .frame(width: 300)
        
            //Progress Bar
            HStack {
                Text(formatTime(Int(trackposition)))
                    .frame(minWidth: 50, maxWidth: 80, minHeight: 20, alignment: .center)
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
                
                CustomSlider(value: $trackposition,
                             inRange: 0...Double(spotifyManager.trackDuration),
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
                
                Text("-\(formatTime(spotifyManager.trackDuration - Int(trackposition)))")
                    .frame(minWidth: 55, maxWidth: 80, minHeight: 20, alignment: .center)
                    .foregroundStyle(.gray)
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
            }.frame(height: 15)
            
            ButtonView()
            
        }
        .background(.black)
        .onReceive(spotifyManager.$trackPosition) { newValue in
            trackposition = Double(newValue)
        }
        .onAppear {
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if spotifyManager.isPlaying == true {
                    trackposition += 1
                }
            }
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }

        .padding(.bottom, 15)
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

    
