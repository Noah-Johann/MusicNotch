//
//  ExtensionHUDView.swift
//  MusicNotch
//
//  Created by Noah Johann on 12.09.25.
//

import SwiftUI

enum HudType {
    case volume
    case brightness
}

struct ExtensionHUDViewLeading: View {
    @ObservedObject var volumeManager = VolumeManager.shared
    let hudType: HudType
    
    var body: some View {
        switch hudType {
        case .volume:
            HStack {
                HStack {
                    if volumeManager.volume == 0 {
                        Image(systemName: "speaker.slash.fill")
                    } else if volumeManager.volume < 0.4 {
                        Image(systemName: "speaker.wave.1.fill")
                    } else if volumeManager.volume < 0.7 {
                        Image(systemName: "speaker.wave.2.fill")
                    } else {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                } .frame(width: 20)
                
                Text("Volume")
                    .font(.system(size: 12))
            } .frame(width: 80)
                .padding(.trailing, 4)
            
        case .brightness:
            Label("Brightness", systemImage: "sun.max.fill")
        }
    }
}

struct ExtensionHUDViewTrailing: View {
    @ObservedObject var volumeManager = VolumeManager.shared
    let hudType: HudType
    
    var body: some View {
        switch hudType {
        case .volume:
            HStack {
                HudSlider(value: $volumeManager.volume)
                
                if volumeManager.isMuted {
                    Text("muted")
                }
            } .frame(width: 80)
                .padding(.leading, 4)
            
        case .brightness:
            Label("Brightness", systemImage: "sun.max.fill")
        }
    }
}

#Preview {
    ExtensionHUDViewTrailing(hudType: .volume)
        .padding()
}
 
