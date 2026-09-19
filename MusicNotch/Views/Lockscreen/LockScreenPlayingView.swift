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
        
    var body: some View {
        VStack {
            VStack (){
                HStack (alignment: .center) {
                    AlbumArtView(
                        playing: $musicManager.music.isPlaying,
                        size: 70,
                        shrink: 8,
                        cornerRadius: 13,
                        nsImage: musicManager.albumArt ?? NSImage(named: "no_playback")!,
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
                } .frame(height: 90)
                
                MusicProgressBarView(width: 305, coloredProgressBar: false)
                
                PlayerButtonView(enableSpeaker: false)
                    .padding(.bottom, 20)
                    .environment(\EnvironmentValues.colorScheme, .dark)
            } .frame(height: 190)
        }
        .frame(width: 350, height: 190)
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
        .background {
            if #available(macOS 26, *) {
                GlassView(style: .clear, cornerRadius: 30)
                    .environment(\.controlActiveState, .active)
            } else {
                ZStack {
                    MaterialView(
                        material: .menu,
                        blendingMode: .behindWindow
                    )
                    
                    Rectangle()
                        .foregroundStyle(.tint)
                        .blendMode(.multiply)
                }
            }
        }
    }
}

class MusicPlayerWindow: NSPanel {
    override var canBecomeKey: Bool {
        true
    }
    
    override var canBecomeMain: Bool {
        true
    }
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 190),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.backgroundColor = .clear
        self.hasShadow = false
        
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        self.isFloatingPanel = true
        
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
