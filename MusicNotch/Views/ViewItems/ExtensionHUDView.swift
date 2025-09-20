//
//  ExtensionHUDView.swift
//  MusicNotch
//
//  Created by Noah Johann on 12.09.25.
//

import SwiftUI
import AppKit

enum HudType {
    case volume
    case brightness
}

struct ExtensionHUDViewLeading: View {
    @ObservedObject var volumeManager = VolumeManager.shared
    @ObservedObject var brightnessManager = BrightnessManager.shared
    
    let hudType: HudType
    
    var body: some View {
        switch hudType {
        case .volume:
            HStack {
                HStack {
                    if volumeManager.volume == 0 || volumeManager.isMuted {
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
            }
            .frame(width: 35 + textWidth("Volume", font: .systemFont(ofSize: 12)), height: 20)
            .padding(.trailing, 4)
            .animation(.easeInOut(duration: 0.4), value: volumeManager.volume)
            .animation(.easeInOut(duration: 0.4), value: volumeManager.isMuted)
            
            
        case .brightness:
            HStack {
                HStack {
                    if brightnessManager.brightness < 0.4 {
                        Image(systemName: "sun.min")
                    } else {
                        Image(systemName: "sun.max")
                    }
                } .frame(width: 20)
                
                Text("Brightness")
                    .font(.system(size: 12))
            }
            .frame(width: 35 + textWidth("Brightness", font: .systemFont(ofSize: 12)), height: 20)
            .padding(.trailing, 4)
            .animation(.easeInOut(duration: 0.4), value: brightnessManager.brightness)
        }
    }
}

struct ExtensionHUDViewTrailing: View {
    @ObservedObject var volumeManager = VolumeManager.shared
    @ObservedObject var brightnessManager = BrightnessManager.shared
    
    let hudType: HudType
    
    var body: some View {
        switch hudType {
        case .volume:
            HStack {
                HudSlider(value: $volumeManager.volume)
                
                if volumeManager.volume == 0 || volumeManager.isMuted {
                    Text("muted")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 35 + textWidth("Volume", font: .systemFont(ofSize: 12)), height: 20)
            .padding(.leading, 4)
            .animation(.easeInOut(duration: 0.4), value: volumeManager.volume)
            .animation(.bouncy(duration: 0.4), value: volumeManager.isMuted)
            
        case .brightness:
            HStack {
                HudSlider(value: $brightnessManager.brightness)
            }
            .frame(width: 35 + textWidth("Brightness", font: .systemFont(ofSize: 12)), height: 20)
            .padding(.leading, 4)
            .animation(.easeInOut(duration: 0.4), value: brightnessManager.brightness)
        }
    }
}

func textWidth(_ key: String, font: NSFont) -> CGFloat {
    let localized = NSLocalizedString(key, comment: "")
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    let frameWidth = (localized as NSString).size(withAttributes: attributes).width
    if frameWidth > 80 {
        return frameWidth
    } else {
        return 80.0
    }
}

#Preview {
    ExtensionHUDViewTrailing(hudType: .volume)
        .padding()
}
 
