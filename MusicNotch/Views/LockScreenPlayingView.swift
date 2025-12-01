//
//  LockScreenPlayingView.swift
//  MusicNotch
//
//  Created by Noah Johann on 29.11.25.
//

import SwiftUI
import AppKit
import Defaults

struct LockScreenPlayingView: View {
    @ObservedObject private var spotifyManager = SpotifyManager.shared
    @ObservedObject private var volumeManager = VolumeManager.shared
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    
    @State private var trackposition: Double = 0
    @State private var isDragging: Bool = false
    @State private var playbackTimer: Timer?
        
    @Default(.coloredSpect) private var coloredSpect
    
    var body: some View {
        ZStack {
            VStack {
                VStack (){
                    HStack (alignment: .center) {
                        AlbumArtView(size: 70,
                                     shrink: 8,
                                     cornerRadius: 13,
                                     glow: false,
                        )
                        .padding(.top, 10)
                        .padding(.leading, 17)
                        .padding(.trailing, 4)
                        
                        VStack (alignment: .leading, spacing: 4) {
                            Text(spotifyManager.isSpotifyRunning ? spotifyManager.trackName : "Nothing playing")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(height: 27, alignment: .bottom)
                            Text(spotifyManager.isSpotifyRunning ? spotifyManager.artistName : "Start a song on Spotify")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.gray)
                                .frame(height: 17, alignment: .top)
                        } .frame(height: 70, alignment: .center)
                        
                        Spacer()
                        
                        if !accessibilityManager.isReduceMotion {
                            Rectangle()
                                .fill(coloredSpect ? Color(nsColor: spotifyManager.aveColor ?? .white).gradient : Color.white.gradient)
                                .frame(width: 35, height: 45, alignment: .center)
                                .mask {
                                    AudioSpectrumView(isPlaying: $spotifyManager.isPlaying)
                                        .frame(width: 30, height: 30)
                                }
                                .padding(.bottom, 17)
                                .padding(.trailing, 10)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 35)
                        }
                    } .frame(height: 90)
                    
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
                        }) .frame(width: 200, height: 10, alignment: .center)
                        
                        Text("-\(formatTime(spotifyManager.trackDuration - Int(trackposition)))")
                            .frame(minWidth: 55, maxWidth: 80, minHeight: 20, alignment: .center)
                            .foregroundStyle(.gray)
                            .fontWeight(.semibold)
                            .font(.system(size: 12))
                    }.frame(height: 15)
                        .padding(.bottom, 6)
                    
                    
                    HStack {
                        Button(action: {
                            spotifyShuffle()
                        })
                        {
                            VStack (spacing: 3){
                                Image(systemName: "shuffle")
                                    .imageScale(.large)
                                    .font(.system(size: 17))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20, height: 20)
                                if spotifyManager.shuffle {
                                    Circle()
                                        .fill(Color.secondary)
                                        .frame(width: 3, height: 3)
                                }
                            }            .transition(.opacity.combined(with: .scale))
                                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: spotifyManager.shuffle)
                        }
                        .background(Color.clear)
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.horizontal, 17)
                        
                        
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
                        
                        
                        Button(action: {
                            spotifyPlayPause()
                        }) {
                            Image(systemName: spotifyManager.isPlaying ? "pause.fill" : "play.fill")
                                .imageScale(.large)
                                .foregroundStyle(.primary)
                                .font(.system(size: 22, weight: .bold))
                                .frame(width: 30, height: 30)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .background(Color.clear)
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.horizontal, 16)
                        
                        
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
                        
                        
                        
                        Image(systemName: volumeManager.deviceIcon)
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 17))
                            .frame(width: 30, height: 30)
                            .padding(.horizontal, 17)
                        
                    }
                    .frame(height: 40)
                    .padding(.bottom, 20)
                } .frame(height: 190)
            }
        }
        .frame(width: 350, height: 190)
        .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .background(.clear)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .onReceive(spotifyManager.$trackPosition) { newValue in
            trackposition = Double(newValue)
        }
        .onAppear {
            trackposition = Double(spotifyManager.trackPosition)
            playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task { @MainActor in
                    if spotifyManager.isPlaying == true {
                        trackposition += 1
                    }
                }
            }
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }
        .contextMenu {
            Text("Version \(Bundle.main.appVersion!)")
                .foregroundStyle(.secondary)
            Section {
                Button("Hide player") {
                    WindowManager.hideLockScreen()
                } .keyboardShortcut("H", modifiers: .command)
                Button("Quit") {
                    NSApp.terminate(nil)
                } .keyboardShortcut("Q", modifiers: .command)
            }
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

class MusicPlayerWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 190),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        
        self.contentView = NSHostingView(rootView: LockScreenPlayingView().moveToSky())
        
        if let screen = NSScreen.screens.first {
            let screenFrame = screen.visibleFrame

            self.setFrameOrigin(NSPoint(x: (screenFrame.maxX / 2) - 175, y: (screenFrame.maxY / 6) + Defaults[.lockPosition]))
        } else {
            self.setFrameOrigin(NSPoint(x: 500, y: 200 + Defaults[.lockPosition]))
        }
    }
}

#Preview {
    ZStack {
        RoundedRectangle(cornerRadius: 30)
            .fill(Color.red)
            .frame(width: 100, height: 300)
        
        LockScreenPlayingView()
    }

        
        .padding()
}
