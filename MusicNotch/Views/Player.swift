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

    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    @State private var isDragging = false
    @State private var trackposition : Double = 0
    @State private var playbackTimer: Timer?
    
    @State private var albumArtSizeOpen = 80.0
    @State public var albumArtSizeClosed = 30.0

    @State private var isHovered = false
    @State private var lastHoverState: Bool = false
    @State private var lastNotchState: String = ""
    
    @State var notchState: String
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    if let albumArt = spotifyManager.albumArtImage {
                        Image(nsImage: albumArt)
                            .resizable()
                            .scaledToFit()
                            .frame(width: notchState == "open" ? albumArtSizeOpen : albumArtSizeClosed,
                                   height: notchState == "open" ? albumArtSizeOpen : albumArtSizeClosed)                            .cornerRadius(6)
                            .padding(.vertical, 10)
                            .animation(.easeInOut(duration: 0.3), value: albumArtSizeOpen)
                        
                    }
                }
                .frame(width: notchState == "open" ? 80 : 30,
                       height: notchState == "open" ? 80 : 30)
                .padding(.leading, notchState == "closed" ? 3 : 0)
                .padding(.trailing, notchState == "closed" ? 230 : 0)
                
                if notchState == "open" {
                    VStack {
                        Text(spotifyManager.trackName)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 260, alignment: .leading)
                        Text(spotifyManager.artistName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .frame(width: 260, alignment: .leading)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 27)
                }
                
                AudioSpectrumView(isPlaying: spotifyManager.isPlaying)
                    .foregroundColor(.white)
                    .frame(width: notchState == "open" ? 20 : 15,
                            height: notchState == "open" ? 20 : 15)
                    .padding(.top, notchState == "open" ? 10 : 0)
                
            }

            .frame(width: notchState == "open" ? 300 : 284)
            
            if notchState == "open" {
                //Progress Bar
                HStack {
                    Text(formatTime(Int(trackposition)))
                        .frame(minWidth: 50, maxWidth: 80, minHeight: 20, alignment: .center)
                        .foregroundColor(.secondary)
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
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                        .font(.system(size: 12))
                }
            }
            if notchState == "open" {
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
        .onChange(of: spotifyManager.isPlaying) {
            changeArtSize(spotifyManager.isPlaying)
        }
        .padding(.bottom, notchState == "open" ? 15 : 0)
        .padding(.top, notchState == "open" ? 10 : 0)
        .animation(.easeInOut)
        .onHover { hovering in
            isHovered = hovering
            if openNotchOnHover == true {
                changeHoverState(hovering)

            }
        }
        
        
    }
    
    private func progressChanged() {
        print("Neuer Wert: \(trackposition)")
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
    
    func changeArtSize (_ playbackState: Bool) {
        if notchState == "open" {
            if playbackState == true {
                albumArtSizeOpen = 80
            } else if playbackState == false {
                albumArtSizeOpen = 70
            }
        } else if notchState == "closed" {
            if playbackState == true {
                albumArtSizeClosed = 30.0
            } else if playbackState == false {
                albumArtSizeClosed = 25.0
            }
        }
    }
    
    func changeHoverState(_ hovering: Bool) {
        let desiredState = hovering ? "open" : "closed"
        if desiredState != notchState && desiredState != lastNotchState {
            lastNotchState = desiredState
            MusicNotchApp.updateNotch()
        }
    }
}

#Preview {
    Player(notchState: "open")
}
