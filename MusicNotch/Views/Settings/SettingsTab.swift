//
//  SettingsTab.swift
//  MusicNotch
//
//  Created by Noah Johann on 08.03.26.
//  Based on: https://github.com/MrKai77/Loop/blob/develop/Loop/Settings%20Window/SettingsTab.swift
//

import SwiftUI
import Luminare
import JochexUI

enum SettingsTab: CaseIterable, @MainActor JochexTabItem {

    case general
    
    case nowPlaying
    case glances
    case lockscreen
    case shortcuts
    
    case about

    var id: String { String(describing: self) }
    
    var name: LocalizedStringKey {
        switch self {
        case .general:
            "General"
        case .nowPlaying:
            "Now Playing"
        case .glances:
            "Glances"
        case .lockscreen:
            "Lock Screen"
        case .shortcuts:
            "Shortcuts"
        case .about:
            "About"
        }
    }
    
    var icon: Image {
        switch self {
        case .general: Image(systemName: "gear")
        case .nowPlaying: Image(systemName: "play.fill")
        case .glances: Image(systemName: "eye.fill")
        case .lockscreen: Image(systemName: "lock.fill")
        case .shortcuts: Image(systemName: "keyboard.fill")
        case .about: Image(systemName: "info.circle.fill")
        }
    }
    
    var buttonAction: () -> () {
        return {}
    }

    @ViewBuilder func view() -> some View {
        switch self {
        case .general:
            SettingsGeneralView()
            SettingsDisplayView()
            SettingsNotchView()
            SettingsGesturesView()
        case .nowPlaying:
            SettingsMusicView()
            SettingsAppearanceView()
            SettingsMusicGlanceView()
        case .glances:
            SettingsExtensionView()
        case .lockscreen:
            SettingsLockScreenView()
        case .shortcuts:
            SettingsShortcutsView()
        case .about:
            SettingsAboutView()
        }
    }
    
    static let generalTabs: [Self] = [.general]
    static let middleTabs: [Self] = [.nowPlaying, .glances, .lockscreen, .shortcuts]
    static let aboutTabs: [Self] = [.about]
}


