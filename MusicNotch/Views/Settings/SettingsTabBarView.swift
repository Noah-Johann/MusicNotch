//
//  SettingsTabBarView.swift
//  MusicNotch
//
//  Created by Noah Johann on 06.04.26.
//

import SwiftUI
import Luminare
import JochexUI

struct SettingsTabBarView: View {
    @State private var vm = SettingsViewManager.shared
    
    var body: some View {
        JochexTabBar(glass: false, isExpanded: $vm.isExpanded) {
            JochexTabBarSection(selectedTab: $vm.selection, isExpanded: $vm.isExpanded, tabs: SettingsTab.generalTabs)
            JochexTabBarSection(selectedTab: $vm.selection, isExpanded: $vm.isExpanded, tabs: SettingsTab.middleTabs)  { Divider() }
            JochexTabBarSection(selectedTab: $vm.selection, isExpanded: $vm.isExpanded, tabs: SettingsTab.aboutTabs)  { Divider() }

        }
    }
}

#Preview {
    SettingsTabBarView()
}
