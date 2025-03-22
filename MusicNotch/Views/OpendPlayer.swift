//
//  OpendPlayer.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//
import SwiftUI
import DynamicNotchKit


struct OpendPlayer: View {
    static let shared = OpendPlayer()

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
                        .frame(width: 80, height: 80)
                        .cornerRadius(6)
                        .padding(.vertical, 10)
                }
                
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
                
                AudioSpectrumView(isPlaying: spotifyManager.isPlaying)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .padding(.top)
                    .padding(.trailing, 0)
                
            } .frame(width: 300)
            
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
        .onReceive(spotifyManager.$trackPosition) { newValue in
            if !isDragging {
                trackposition = Double(newValue)
            }
        } .padding(.bottom, 15)
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
}

//#Preview {
//    OpendPlayer()
//}
