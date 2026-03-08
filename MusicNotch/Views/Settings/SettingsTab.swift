//
//  SettingsTab.swift
//  MusicNotch
//
//  Created by Noah Johann on 08.03.26.
//  Based on: https://github.com/MrKai77/Loop/blob/develop/Loop/Settings%20Window/SettingsTab.swift
//

import SwiftUI
import Luminare

enum SettingsTab: CaseIterable, @MainActor LuminareTabItem {
    
    case general
    
    case nowPlaying
    case glances
    case lockscreen
    case shortcuts
    
    case about

    var id: String { title }
    
    var title: String {
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
    
    var image: Image {
        switch self {
        case .general: Image(systemName: "gear")
        case .nowPlaying: Image(systemName: "play.fill")
        case .glances: Image(systemName: "eye.fill")
        case .lockscreen: Image(systemName: "lock.fill")
        case .shortcuts: Image(systemName: "keyboard.fill")
        case .about: Image(systemName: "info.circle.fill")
        }
    }
    
    var color: Color {
//        switch self {
//        case .general:
//            Color.accentColor
//        case .nowPlaying:
//            <#code#>
//        case .glances:
//            <#code#>
//        case .lockscreen:
//            <#code#>
//        case .shortcuts:
//            <#code#>
//        case .about:
//            <#code#>
//        }
        Color.accentColor
    }
    
    var icon: some View {
        iconView(tab: self)
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
    
    @ViewBuilder func iconView(tab: SettingsTab) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .foregroundStyle(tab.color.gradient)
            .overlay {
                tab.image
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white)
                    .shadow(color: .black.opacity(0.4), radius: 1)
            } .frame(width: 22, height: 22)
    }
    
    static let generalTabs: [Self] = [.general]
    static let middleTabs: [Self] = [.nowPlaying, .glances, .lockscreen, .shortcuts]
    static let aboutTabs: [Self] = [.about]
}


