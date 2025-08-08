//
//  ExtensionBatteryView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
    
struct ExtensionBatteryViewLeading: View {
    var body: some View {
        Image(systemName: BatteryManager.shared.batteryIconName)
            .resizable()
            .scaledToFit()
            .foregroundColor(BatteryManager.shared.batteryIconColor)
            .frame(width: 30, height: 30)
            .opacity(0.8)
    }
}
    
struct ExtensionBatteryViewTrailing: View {
    var body: some View {
        Text("\(Int(BatteryManager.shared.currentCapacity)) %")
            .foregroundColor(BatteryManager.shared.batteryIconColor)
            .fontWeight(.bold)
            .frame(height: 30)
            .opacity(0.8)
    }
}



//#Preview {
//    ExtensionBatteryView()
//}
