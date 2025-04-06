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
    
    static let launchAtLogin = Key<Bool>("LaunchAtLogin", default: LaunchAtLogin.isEnabled)
    
    static let hideNotchTime = Key<CGFloat>("hideNotchTime", default: 3)
    static let notchSizeChange = Key<CGFloat>("notchSizeChange", default: 0)
}

