//
//  SettingsView.swift
//  MusicNotch
//
//  Created by Noah Johann on 27.03.25.
//

import SwiftUI
import Luminare
import JochexUI
import Defaults
import LaunchAtLogin
import KeyboardShortcuts


struct SettingsView: View {
    @Default(.lowPowerWarning) private var lowPowerWarning
    @Default(.bluetoothRecognition) private var bluetoothRecognition
    @Default(.enableGestures) private var enableGestures
    @Default(.hoverBehavior) private var hoverBehavior
    @Default(.autoMusicGlance) private var autoMusicGlance
    @Default(.autoPlayer) private var autoPlayer
    
    @State private var updateManager = UpdateManager.shared
    
    @State private var vm = SettingsViewManager.shared
    
    @Environment(\.luminareTitleBarHeight) private var titleBarPadding
    
    var body: some View {
        JochexPane {
            HStack {
                vm.selection.icon
                Text(vm.selection.name).font(.title2)
            } .drawingGroup()
        } content: {
            vm.selection.view()
                .padding()
        }
        
//        LuminareDividedStack {
//            LuminareSidebar {
//                LuminareSidebarSection(selection: $settingsTab, items: SettingsTab.generalTabs)
//                LuminareSidebarSection(selection: $settingsTab, items: SettingsTab.middleTabs)
//                LuminareSidebarSection(selection: $settingsTab, items: SettingsTab.aboutTabs)
//            }
//            .frame(width: 220)
//            .padding(.top, titleBarPadding)
//            .luminareBackground()
//            
//            LuminarePane {
//                settingsTab.view()
//            } header: {
//                HStack {
//                    settingsTab.icon
//                    Text(settingsTab.title).font(.title2)
//                    Spacer()
//                } .drawingGroup()
//            }
//        }
//        .luminareTint(overridingWith: .accentColor)
//        .ignoresSafeArea()
        
//        LuminarePane() {
//            VStack {
//                SettingsGeneralView()
//                
//                SettingsDisplayView()
//                
//                SettingsNotchView()
//                
//                SettingsGesturesView()
//                
//                SettingsMusicView()
//                
//                SettingsAppearanceView()
//                
//                SettingsMusicGlanceView()
//                
//                SettingsExtensionView()
//                
//                SettingsLockScreenView()
//                                
//                SettingsShortcutsView()
//                
//                SettingsAboutView()
//            }
//            .padding(.horizontal, 5)
//            .animation(.easeInOut(duration: 0.3), value: lowPowerWarning)
//            .animation(.easeInOut(duration: 0.3), value: bluetoothRecognition)
//            .animation(.easeInOut(duration: 0.3), value: enableGestures)
//            .animation(.easeInOut(duration: 0.3), value: hoverBehavior)
//            .animation(.easeInOut(duration: 0.3), value: autoMusicGlance)
//            .animation(.easeInOut(duration: 0.3), value: updateManager.updateState)
//            .animation(.bouncy(duration: 0.2), value: updateManager.updateProgress)
//            .animation(.bouncy(duration: 0.3), value: autoPlayer)
//
//        }
    }
}
#Preview {
    SettingsView()
}
