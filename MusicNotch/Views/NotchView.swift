//
//  notchView.swift
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
                ExtensionBatteryViewLeading()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .volume {
                ExtensionHUDViewLeading(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .brightness {
                 ExtensionHUDViewLeading(hudType: .brightness)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .locked {
                ExtensionLockViewLeading(lockType: .locked)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .unlocked {
                ExtensionLockViewLeading(lockType: .unlocked)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .bluetooth {
                AirPodsNotchViewLeading()
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
                ExtensionBatteryViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .volume {
                ExtensionHUDViewTrailing(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .brightness {
                ExtensionHUDViewTrailing(hudType: .brightness)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .locked {
                ExtensionLockViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .unlocked {
                ExtensionLockViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .bluetooth {
                AirPodsNotchViewTrailing()
                    .transition(.blurReplace)
            }
        }
    }
}

struct NotchViewExpanded: View {
    @ObservedObject var notchContentManager = NotchContentState.shared
    
    @ObservedObject var volumeManager = VolumeManager.shared
    @ObservedObject var brightnessManager = BrightnessManager.shared
    @ObservedObject var keyboardManager = KeyboardManager.shared
    @ObservedObject var lockScreenManager = LockScreenManager.shared
    
    @Default(.activateGadgets) private var activateGadgets
    @Default(.topGadgets) private var topGadgets
    @Default(.bottomGadgets) private var bottomGadgets
    @Default(.batteryGadget) private var batteryGadget
    @Default(.settingsGadget) private var settingsGadget
    
    var body: some View {
        VStack {
            if topGadgets && activateGadgets {
                HStack (spacing: 15) {
                    Spacer()
                    if batteryGadget {
                        BasicBatteryIconView(iconWidth: notchContentManager.notchContent == .battery ? 80 : 30)
                    }
                    if notchContentManager.notchContent != .battery || !batteryGadget {
                        if settingsGadget {
                            Button {
                                WindowManager.openSettings()
                            } label: {
                                Image(systemName: "gear")
                            } .buttonStyle(PlainButtonStyle())
                        }
                    }
                } .padding(.horizontal)
                    .padding(.top, notchContentManager.notchContent == .battery ? 10 : 2)
            }
            
            Player()
            
            if notchContentManager.notchContent == .volume {
                ExtensionHUDViewExpanded(hudType: .volume)
            } else if notchContentManager.notchContent == .brightness {
                ExtensionHUDViewExpanded(hudType: .brightness)
            }
            
            if bottomGadgets && activateGadgets {
                HStack (spacing: 15) {
                    Spacer()
                    if batteryGadget {
                        BasicBatteryIconView(iconWidth: notchContentManager.notchContent == .battery ? 80 : 30)
                    }
                    if notchContentManager.notchContent != .battery || !batteryGadget {
                        if settingsGadget {
                            Button {
                                WindowManager.openSettings()
                            } label: {
                                Image(systemName: "gear")
                            } .buttonStyle(PlainButtonStyle())
                        }
                    }
                } .padding(.horizontal)
                    .padding(.bottom)
            }
        } .padding(.bottom)
    }
}


class NotchContentState: ObservableObject {
    static let shared = NotchContentState()
    
    @Published var notchContent: NotchContent = .music
    
}


