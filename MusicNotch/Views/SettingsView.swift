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
    @Default(.globalMusicGlance) private var autoMusicGlance
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
                .animation(.easeInOut(duration: 0.3), value: lowPowerWarning)
                .animation(.easeInOut(duration: 0.3), value: bluetoothRecognition)
                .animation(.easeInOut(duration: 0.3), value: enableGestures)
                .animation(.easeInOut(duration: 0.3), value: hoverBehavior)
                .animation(.easeInOut(duration: 0.3), value: autoMusicGlance)
                .animation(.easeInOut(duration: 0.3), value: updateManager.updateState)
                .animation(.easeInOut(duration: 0.3), value: updateManager.updateProgress)
                .animation(.easeInOut(duration: 0.3), value: autoPlayer)
            
        } .jochexUseGlassIfAvailable(true)
    }
}
#Preview {
    SettingsView()
}
