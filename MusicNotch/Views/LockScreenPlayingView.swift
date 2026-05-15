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
    @State private var musicManager = MusicManager.shared
    @State private var volumeManager = VolumeManager.shared
  //  @State private var accessibilityManager = AccessibilityManager.shared
    
    @State private var trackposition: Double = 0
    @State private var isDragging: Bool = false
    @State private var playbackTimer: Timer?
        
    @Default(.coloredSpect) private var coloredSpect
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.ultraThinMaterial)
            
            VStack {
                VStack (){
                    HStack (alignment: .center) {
                        AlbumArtView(size: 70,
                                     shrink: 8,
                                     cornerRadius: 13,
                        )
                        .padding(.top, 10)
                        .padding(.leading, 17)
                        .padding(.trailing, 4)
                        
                        VStack (alignment: .leading, spacing: 4) {
                            Text(musicManager.music.trackName)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .frame(height: 27, alignment: .bottom)
                            Text(musicManager.music.artistName)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.gray)
                                .frame(height: 17, alignment: .top)
                        } .frame(height: 70, alignment: .center)
                        
                        Spacer()
                        
//                        if !accessibilityManager.isReduceMotion {
//                            Rectangle()
//                                .fill(coloredSpect ? Color(nsColor: musicManager.aveColor ?? .white).gradient : Color.white.gradient)
//                                .frame(width: 35, height: 45, alignment: .center)
//                                .mask {
//                                    AudioSpectrumView(isPlaying: $musicManager.music.isPlaying)
//                                        .frame(width: 30, height: 30)
//                                }
//                                .padding(.bottom, 17)
//                                .padding(.trailing, 10)
//                        } else {
//                            Rectangle()
//                                .fill(Color.clear)
//                                .frame(width: 35)
//                        }
                    } .frame(height: 90)
                    
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
                                MusicActions.setProgress(position: trackposition)
                            }
                        }) .frame(width: 200, height: 10, alignment: .center)
                        
                        Text("-\(formatTime(musicManager.music.trackDuration - Int(trackposition)))")
                            .frame(minWidth: 55, maxWidth: 80, minHeight: 20, alignment: .center)
                            .foregroundStyle(.gray)
                            .fontWeight(.semibold)
                            .font(.system(size: 12))
                    }.frame(height: 15)
                        .padding(.bottom, 6)
                    
                    
                    PlayerButtonView(enableSpeaker: false)
                        .padding(.bottom, 20)
                } .frame(height: 190)
            }
        }
        .frame(width: 350, height: 190)
        .onChange(of: musicManager.music.trackPosition) { _, newValue in
            trackposition = Double(newValue)
        }
        .onAppear {
            trackposition = Double(musicManager.music.trackPosition)
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
        .contextMenu {
            Text("Version \(Bundle.main.appVersion!)")
                .foregroundStyle(.secondary)
            Section {
                Button("Hide player") {
                    WindowManager.shared.hideLockScreen()
                } .keyboardShortcut("H", modifiers: .command)
                Button("Quit") {
                    NSApp.terminate(nil)
                } .keyboardShortcut("Q", modifiers: .command)
            }
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
    } .padding()
}
