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
    @Default(.openNotchOnHover) private var openNotchOnHover
    @Default(.openingDelay) private var openingDelay
    @Default(.hapticFeedback) private var hapticFeedback

    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @State private var isDragging = false
    @State private var trackposition : Double = 0
    @State private var playbackTimer: Timer?
    
    

    @State private var isHovered = false
    @State private var lastHoverState: Bool = false
    @State private var lastNotchState: String = ""
        
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
                
                
                AudioSpectrumView(isPlaying: $spotifyManager.isPlaying)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(.top, 10)
                
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
        .onReceive(spotifyManager.$trackPosition) { newValue in
            trackposition = Double(newValue)
        }
        .onAppear {
            if spotifyManager.isPlaying == true {
                playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    if spotifyManager.isPlaying == true {
                        trackposition += 1
                    }
                }
            }
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }

        .padding(.bottom, 15)
        .padding(.top, 10)
        .onHover { hovering in
            isHovered = hovering

            // Prevent redundant state changes
            if hovering != lastHoverState {
                lastHoverState = hovering

                if openNotchOnHover {
                    DispatchQueue.main.asyncAfter(deadline: .now() + openingDelay) {
                        if isHovered == lastHoverState {
                           // changeHoverState(isHovered)
                        }
                    }
                }
            }

            if hapticFeedback {
                let performer = NSHapticFeedbackManager.defaultPerformer
                performer.perform(.alignment, performanceTime: .default)
            }
        } .contextMenu {
            ContextMenuView()
        }
        
        
        
    }
    
    private func progressChanged() {
        print("new value: \(trackposition)")
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
    
    
    
//    func changeHoverState(_ hovering: Bool) {
//        let desiredState = hovering ? "open" : "closed"
//        if desiredState != notchStateS && desiredState != notchState && desiredState != lastNotchState {
//            lastNotchState = desiredState
//            //MusicNotchApp.updateNotch()
//            print("-----------")
//            print("Hoverstate\(hovering)")
//            print("Notchstate before \(notchState)")
//            DispatchQueue.main.async {
//                MusicNotchApp.setNotchContent(desiredState)
//            }
//            print("Change hover notch")
//
//        }
//    }
}

#Preview {
    Player()
}

    
