//
//  Variables.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.03.25.
//

import Foundation
import SwiftUI
import Defaults
import LaunchAtLogin

extension Defaults.Keys {
    // General
    static let viewedOnboarding = Key<Bool>("viewedOnboarding", default: false)
    static let showMenuBarItem = Key<Bool>("showMenuBarItem", default: true)
    static let showDockItem = Key<Bool>("showDockItem", default: false)
    
    static let launchAtLogin = Key<Bool>("LaunchAtLogin", default: LaunchAtLogin.isEnabled)
    
    static let autoUpdates = Key<Bool>("autoUpdates", default: true)
    
    // Display
    static let notchDisplay = Key<Bool>("notchDisplay", default: true)
    static let mainDisplay = Key<Bool>("mainDisplay", default: false)
    static let disableNotchOnHide = Key<Bool>("disableNotchOnHide", default: false)
    static let noNotchScreenHide = Key<Bool>("noNotchScreenHide", default: false)
    
    // Appearance
    static let coloredSpect = Key<Bool>("coloredSpect", default: true)
    static let playerGlow = Key<Bool>("playerGlow", default: true)
    
    // Notch
    static let openNotchOnHover = Key<Bool>("openNotchOnHover", default: false)
    static let openingDelay = Key<Double>("openingDelay", default: 0.3)
    static let hapticFeedback = Key<Bool>("hapticFeedback", default: true)
    static let hideNotchTime = Key<Double>("hideNotchTime", default: 3)
    
    // Gestures
    static let enableGestures = Key<Bool>("enableGestures", default: true)
    static let mediaGestures = Key<Bool>("mediaGestures", default: true)
    
    // LockScreen
    static let lockExtension = Key<Bool>("lockExtension", default: true)
    static let lockSound = Key<Bool>("lockSound", default: true)
    static let unlockSound = Key<Bool>("unlockSound", default: true)
    static let lockPlayer = Key<Bool>("lockPlayer", default: true)
    static let lockPosition = Key<Double>("lockPosition", default: 0)
    static let alwaysShowPlayer = Key<Bool>("alwaysShowPlayer", default: false)
    
    // MusicGlance
    static let autoMusicGlance = Key<Bool>("autoMusicGlance", default: true)
    
    // Extensions
    static let displayDuration = Key <Double>("displayDuration", default: 3.0)
    
    static let batteryExtension = Key<Bool>("batteryExtension", default: true)
    
    static let hudExtension = Key<Bool>("hudExtension", default: true)
    static let gradientHudSlider = Key<Bool>("gradientHudSlider", default: true)
    static let accentColorHudSlider = Key<Bool>("accentColorHudSlider", default: false)
    
    static let bluetoothRecognition = Key<Bool>("bluetoothRecognition", default: true)
    static let bluetoothSymbols = Key<Bool>("bluetoothSymbols", default: false)
    static let bluetoothVideos = Key<Bool>("bluetoothVideos", default: true)
    
    // Gadgets
    static let activateGadgets = Key<Bool>("activateGadgets", default: true)
    
    static let topGadgets = Key<Bool>("topGadgets", default: true)
    static let bottomGadgets = Key<Bool>("bottomGadgets", default: false)
    
    static let batteryGadget = Key<Bool>("batteryGadget", default: true)
    static let settingsGadget = Key<Bool>("settingsGadget", default: true)
    
}

