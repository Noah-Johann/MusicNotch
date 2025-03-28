//
//  OpendPlayer.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import SwiftUI
import DynamicNotchKit
import AppKit

func getNotchHeight () -> CGFloat? {
    if let screenWithNotch = NSScreen.screens.first(where: { $0.frame.origin.y != 0 }) {
        let menuBarHeight = screenWithNotch.frame.height - screenWithNotch.visibleFrame.height
        print("Menu bar height (with notch): \(menuBarHeight) pixels")
        return menuBarHeight
    } else {
        print("no notch screen found")
        return 40
    }
}
struct closedPlayer: View {
    static let shared = closedPlayer()

    @ObservedObject var spotifyManager = SpotifyManager.shared
    @State private var isDragging = false
    @State public var sliderValue: Double = 0
    @State private var trackposition : Double = 0
    
    var body: some View {
        VStack {
            HStack {
                
                if let albumArt = spotifyManager.albumArtImage {
                    Image(nsImage: albumArt)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .cornerRadius(6)
                        .padding(.leading, 3)
                        .padding(.trailing, 230)
                }
                AudioSpectrumView(isPlaying: spotifyManager.isPlaying)
                    .foregroundColor(.white)
                    .frame(width: 15, height: 15)
                
            } .frame(width: 284, height: getNotchHeight(), alignment: .center)
            
        }
    }
}

#Preview {
    closedPlayer()
}
