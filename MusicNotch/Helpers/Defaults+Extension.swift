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
    static let viewedOnboarding = Key<Bool>("viewedOnboarding", default: false)
    static let showMenuBarItem = Key<Bool>("showMenuBarItem", default: true)
    
    static let launchAtLogin = Key<Bool>("LaunchAtLogin", default: LaunchAtLogin.isEnabled)
    
    static let notchDisplay = Key<Bool>("notchDisplay", default: true)
    static let mainDisplay = Key<Bool>("mainDisplay", default: false)
    static let disableNotchOnHide = Key<Bool>("disableNotchOnHide", default: false)
    
    static let coloredSpect = Key<Bool>("coloredSpect", default: true)
    
    static let openNotchOnHover = Key<Bool>("openNotchOnHover", default: true)
    static let openingDelay = Key<Double>("openingDelay", default: 0.0)
    static let hapticFeedback = Key<Bool>("hapticFeedback", default: true)
    static let hideNotchTime = Key<Double>("hideNotchTime", default: 3)
}

