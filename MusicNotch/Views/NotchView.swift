//
//  NotchView.swift
//  MusicNotch
//
//  Created by Noah Johann on 07.08.25.
//

import SwiftUI
import Defaults

struct NotchViewLeading: View {
    @State var notchManager = NotchManager.shared
    
    var body: some View {
        ZStack {
            if notchManager.notchContent == .music || notchManager.notchContent == .musicGlance {
                NotchMusicViewLeading()
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .battery {
                NotchBatteryViewLeading()
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .volume {
                NotchHUDViewLeading(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .brightness {
                 NotchHUDViewLeading(hudType: .brightness)
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .locked {
                NotchLockViewLeading(lockType: .locked)
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .unlocked {
                NotchLockViewLeading(lockType: .unlocked)
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .bluetooth {
                NotchAirPodsViewLeading()
                    .transition(.blurReplace)
            }
        } .environment(notchManager)
    }
}

struct NotchViewTrailing: View {
    @State var notchManager = NotchManager.shared
    
    var body: some View {
        ZStack {
            if notchManager.notchContent == .music || notchManager.notchContent == .musicGlance {
                NotchMusicViewTrailing()
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .battery {
                NotchBatteryViewTrailing()
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .volume {
                NotchHUDViewTrailing(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .brightness {
                NotchHUDViewTrailing(hudType: .brightness)
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .locked {
                NotchLockViewTrailing()
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .unlocked {
                NotchLockViewTrailing()
                    .transition(.blurReplace)
            } else if notchManager.notchContent == .bluetooth {
                NotchAirPodsViewTrailing()
                    .transition(.blurReplace)
            }
        } .environment(notchManager)
    }
}

struct NotchViewExpanded: View {
    @State var notchManager = NotchManager.shared
    @State var batteryManager = BatteryManager.shared
    @State var volumeManager = VolumeManager.shared
    @State var brightnessManager = BrightnessManager.shared
    private var lockManager = LockScreenManager()
    private var screenHelper = ScreenHelper()
    private var hideManager = HideManager.shared
    
    var body: some View {
        VStack {
            NotchMusicViewExpanded()
            
            if notchManager.notchContent == .volume {
                NotchHUDViewExpanded(hudType: .volume, width: 330)
            } else if notchManager.notchContent == .brightness {
                NotchHUDViewExpanded(hudType: .brightness, width: 330)
            }
        } .environment(notchManager)
    }
}

