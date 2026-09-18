//
//  MusicProgressBarView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.09.26.
//

import SwiftUI
import Defaults

struct MusicProgressBarView: View {
    var width: CGFloat
    var coloredProgressBar: Bool
    
    @State private var musicManager = MusicManager.shared
    @State private var notchManager = NotchManager.shared
    
    @State private var isDragging = false
    @State private var playbackTimer: Timer?
    @State private var trackPosition: Double = 0
    
    var body: some View {
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
                    activeFillColor: coloredProgressBar == true ? Color(nsColor: musicManager.aveColor ?? .gray) : Color.gray.opacity(0.8),
                    fillColor: musicManager.music.isLive ? Color(NSColor.darkGray).opacity(0.4) : (coloredProgressBar == true ? Color(nsColor: musicManager.aveColor ?? .gray) : .gray.opacity(0.8)),
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
        .frame(width: width, height: 15)
        .padding(.bottom, 3)
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
    }
}

//#Preview {
//    MusicProgressBarView()
//}
