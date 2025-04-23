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
    @Default(.notchSizeChange) private var notchSizeChange
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
    
    //@State var notchStateS: String
    
    var body: some View {
        VStack {
            HStack {
                AlbumArtView(sizeState: "open")
                
                VStack {
                    Text(spotifyManager.trackName)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 260, alignment: .leading)
                    Text(spotifyManager.artistName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                        .frame(width: 260, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .padding(.top, 27)
                
                
                AudioSpectrumView(isPlaying: spotifyManager.isPlaying)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .padding(.top, 10)
                
            } .frame(width: 300)
            
            
            
            
            //Progress Bar
            HStack {
                Text(formatTime(Int(trackposition)))
                    .frame(minWidth: 50, maxWidth: 80, minHeight: 20, alignment: .center)
                    .foregroundColor(.gray)
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
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .font(.system(size: 12))
            }
            
            //Controls
            HStack {
                
                //Shuffle
                Button(action: {
                    spotifyShuffle()
                })
                {
                    
                    Image(systemName: ShuffleIcon)
                        .imageScale(.large)
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, height: 30)
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 17)
                
                
                
                
                //Skip backward
                Button(action: {
                    spotifyLastTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                        .font(.system(size: 17))
                        .frame(width: 30, height: 30)
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 5)
                
                
                
                //Pause
                Button(action: {
                    spotifyPlayPause()
                }) {
                    Image(systemName: PlayIcon)
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: 30, height: 30)
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 16)
                
                
                //Skip forward
                Button(action: {
                    spotifyNextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                        .font(.system(size: 17))
                        .frame(width: 30, height: 30)
                    
                }
                .background(Color.clear)
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 5)
                
                
                //Speaker
                Image(systemName: deviceIcon)
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 17))
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 17)
                
            }
            
        }
        .frame(minHeight: notchHeight + notchSizeChange)
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

    
