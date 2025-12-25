//
//  NotchBatteryView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
    
struct NotchBatteryViewLeading: View {
    @ObservedObject var batteryManager = BatteryManager.shared
    
    var body: some View {
        //        Image(systemName: batteryManager.batteryIconName)
        //            .resizable()
        //            .scaledToFit()
        //            .foregroundColor(batteryManager.batteryIconColor)
        //            .frame(width: 30, height: 30)
        //            .opacity(0.8)
        BasicBatteryIconView(iconWidth: 33)
    }
}
    
struct NotchBatteryViewTrailing: View {
    @ObservedObject var batteryManager = BatteryManager.shared
    
    var body: some View {
        Text("\(Int(batteryManager.currentCapacity)) %")
            .foregroundColor(batteryManager.batteryIconColor)
            .fontWeight(.bold)
            .frame(height: 30)
            .opacity(0.8)
    }
}

