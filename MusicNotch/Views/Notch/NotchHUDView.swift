//
//  NotchHUDView.swift
//  MusicNotch
//
//  Created by Noah Johann on 12.09.25.
//

import SwiftUI
import AppKit
import Defaults

enum HudType {
    case volume
    case brightness
}

struct NotchHUDViewLeading: View {
    @State var volumeManager = VolumeManager.shared
    @State var brightnessManager = BrightnessManager.shared
    
    let hudType: HudType
    
    var body: some View {
        switch hudType {
        case .volume:
            HStack {
                HStack {
                    if Defaults[.hudDeviceIcons] {
                        Image(systemName: volumeManager.deviceIcon)
                    } else {
                        if volumeManager.volume == 0 || volumeManager.isMuted {
                            Image(systemName: "speaker.slash.fill")
                        } else if volumeManager.volume < 0.4 {
                            Image(systemName: "speaker.wave.1.fill")
                        } else if volumeManager.volume < 0.7 {
                            Image(systemName: "speaker.wave.2.fill")
                        } else {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                    }
                }
                .font(.system(size: 12))
                .frame(width: 15)
                
                if !Defaults[.hideHudLabel] {
                    Text("Volume")
                        .font(.system(size: 11))
                        .frame(width: textWidth("Volume", font: .systemFont(ofSize: 11)))
                }
                
                Spacer()
            }
            .frame(width: 32 + textWidth("Volume", font: .systemFont(ofSize: 11)), height: 20)
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
                }
                .font(.system(size: 12))
                .frame(width: 15)
                
                if !Defaults[.hideHudLabel] {
                    Text("Brightness")
                        .font(.system(size: 11))
                }
                
                Spacer()
            }
            .frame(width: 32 + textWidth("Brightness", font: .systemFont(ofSize: 11)), height: 20)
            .padding(.trailing, 4)
            .animation(.easeInOut(duration: 0.4), value: brightnessManager.brightness)
        }
    }
}

struct NotchHUDViewTrailing: View {
    @State var volumeManager = VolumeManager.shared
    @State var brightnessManager = BrightnessManager.shared
    
    let hudType: HudType
    
    var body: some View {
        switch hudType {
        case .volume:
            HStack {
                Spacer()
                HStack {
                    HudSlider(value: $volumeManager.volume)
                    
                    if volumeManager.volume == 0 || volumeManager.isMuted {
                        Text("muted")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .transition(.scale(scale: 0.2).combined(with: .opacity))
                            .id("volume-label")
                    }
                } .frame(width: 77)
            }
            .frame(width: 32 + textWidth("Volume", font: .systemFont(ofSize: 11)), height: 20)
            .padding(.leading, 4)
            .animation(.easeInOut(duration: 0.4), value: volumeManager.volume)
            .animation(.bouncy(duration: 0.4), value: volumeManager.isMuted)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: Defaults[.hideHudLabel])
            
        case .brightness:
            HStack {
                Spacer()
                HudSlider(value: $brightnessManager.brightness)
                    .frame(width: 77)
            }
            .frame(width: 32 + textWidth("Brightness", font: .systemFont(ofSize: 11)), height: 20)
            .padding(.leading, 4)
            .animation(.easeInOut(duration: 0.4), value: brightnessManager.brightness)
        }
    }
}

func textWidth(_ key: String, font: NSFont) -> CGFloat {
    let localized = NSLocalizedString(key, comment: "")
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    let frameWidth = (localized as NSString).size(withAttributes: attributes).width
    if frameWidth > 50 {
        return frameWidth
    } else {
        return 50
    }
}

struct NotchHUDViewExpanded: View {
    @State var volumeManager = VolumeManager.shared
    @State var brightnessManager = BrightnessManager.shared
    
    @State private var musicManager = MusicManager.shared

    
    let hudType: HudType
    let width: CGFloat
    
    var body: some View {
        switch hudType {
        case .volume:
            VStack (spacing: 18) {
                HStack {
                    HStack {
                        if volumeManager.volume == 0 || volumeManager.isMuted {
                            Image(systemName: "speaker.slash.fill")
                                .font(.system(size: 17))
                        } else if volumeManager.volume < 0.4 {
                            Image(systemName: "speaker.wave.1.fill")
                                .font(.system(size: 17))
                        } else if volumeManager.volume < 0.7 {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 17))
                        } else {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 17))
                        }
                    } .frame(width: 20)
                        .padding(.trailing, 5)
                    
                    HStack {
                        HudSlider(value: $volumeManager.volume, height: 6)
                        
                        if volumeManager.volume == 0 || volumeManager.isMuted {
                            Text("muted")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(width: width, height: 30)
                .animation(.easeInOut(duration: 0.3), value: volumeManager.volume)
                .animation(.bouncy(duration: 0.3), value: volumeManager.isMuted)

                if musicManager.music.volume != nil && Defaults[.musicPlayerVolume] {
                    HStack {
                        HStack {
                            Image(systemName: musicManager.music.volume == 0 ? "music.note.slash" : "music.note")
                                .font(.system(size: 17))
                        } .frame(width: 20)
                            .padding(.trailing, 5)
                        
                        HStack {
                            let musicVolumeBinding = Binding<CGFloat>(
                                get: { musicManager.music.volume! / 100 },
                                set: { newValue in musicManager.music.volume = newValue * 100}
                            )
                            HudSlider(value: musicVolumeBinding, height: 6)
                        }
                    }
                    .frame(width: width, height: 30)
                    .animation(.easeInOut(duration: 0.3), value: musicManager.music.volume)
                }
            }
        case .brightness:
            HStack {
                HStack {
                    if brightnessManager.brightness < 0.4 {
                        Image(systemName: "sun.min")
                            .font(.system(size: 17))
                    } else {
                        Image(systemName: "sun.max")
                            .font(.system(size: 17))
                    }
                }
                .frame(width: 20)
                .padding(.trailing, 5)
                
                HStack {
                    HudSlider(value: $brightnessManager.brightness, height: 6)
                }
            }
            .frame(width: width, height: 30)
            .animation(.easeInOut(duration: 0.3), value: brightnessManager.brightness)
        }
    }
}

#Preview {
    NotchHUDViewExpanded(hudType: .volume, width: 390)
        .padding()
}
 

