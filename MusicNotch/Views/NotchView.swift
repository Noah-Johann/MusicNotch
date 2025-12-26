//
//  NotchView.swift
//  MusicNotch
//
//  Created by Noah Johann on 07.08.25.
//

import SwiftUI
import Defaults

struct NotchViewLeading: View {
    @ObservedObject var notchContentManager = NotchContentState.shared
    
    var body: some View {
        ZStack {
            if notchContentManager.notchContent == .music || notchContentManager.notchContent == .musicGlance {
                NotchMusicViewLeading()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .battery {
                NotchBatteryViewLeading()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .volume {
                NotchHUDViewLeading(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .brightness {
                 NotchHUDViewLeading(hudType: .brightness)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .locked {
                NotchLockViewLeading(lockType: .locked)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .unlocked {
                NotchLockViewLeading(lockType: .unlocked)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .bluetooth {
                NotchAirPodsViewLeading()
                    .transition(.blurReplace)
            }
        }
    }
}

struct NotchViewTrailing: View {
    @ObservedObject var notchContentManager = NotchContentState.shared
    
    var body: some View {
        ZStack {
            if notchContentManager.notchContent == .music || notchContentManager.notchContent == .musicGlance {
                NotchMusicViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .battery {
                NotchBatteryViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .volume {
                NotchHUDViewTrailing(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .brightness {
                NotchHUDViewTrailing(hudType: .brightness)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .locked {
                NotchLockViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .unlocked {
                NotchLockViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .bluetooth {
                NotchAirPodsViewTrailing()
                    .transition(.blurReplace)
            }
        }
    }
}

struct NotchViewExpanded: View {
    @ObservedObject var notchContentManager = NotchContentState.shared
    
    @ObservedObject var batteryManager = BatteryManager.shared
    @ObservedObject var volumeManager = VolumeManager.shared
    @ObservedObject var brightnessManager = BrightnessManager.shared
    @ObservedObject var keyboardManager = KeyboardManager.shared
    @ObservedObject var lockScreenManager = LockScreenManager.shared
    
    var body: some View {
        VStack {
            NotchMusicViewExpanded()
            
            if notchContentManager.notchContent == .volume {
                NotchHUDViewExpanded(hudType: .volume, width: 350)
            } else if notchContentManager.notchContent == .brightness {
                NotchHUDViewExpanded(hudType: .brightness, width: 350)
            }
        } .padding(.bottom)
    }
}


class NotchContentState: ObservableObject {
    static let shared = NotchContentState()
    
    @Published var notchContent: NotchContent = .music
    
}


