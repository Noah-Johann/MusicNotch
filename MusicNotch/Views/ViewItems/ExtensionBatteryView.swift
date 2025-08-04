//
//  ExtensionBatteryView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI

//enum BatteryColorStatus {
//    case lowPowerMode
//    case lowPowerCharging
//    case charging
//    case empty
//    case normal
//}
//    
//var BatteryStatus: BatteryColorStatus {
//    if BatteryManager.shared.isLowPowerMode == true && BatteryManager.shared.isCharging == false {
//        return .lowPowerMode
//    } else if BatteryManager.shared.isCharging == true && BatteryManager.shared.isLowPowerMode == false {
//        return .charging
//    } else if BatteryManager.shared.isLowPowerMode == true && BatteryManager.shared.isCharging == true {
//        return .lowPowerCharging
//    } else if BatteryManager.shared.batteryPercentage < 10 {
//        return .empty
//    } else {
//        return .normal
//    }
//}
//
//var BatteryIconName: String = "battery.100percent"
//    
//    
//var BatteryIconColor: Color {
//    switch BatteryStatus {
//    case .lowPowerMode:
//        BatteryIconName = "battery.100percent"
//        return .yellow
//    case .charging:
//        BatteryIconName = "battery.100percent.bolt"
//        return .green
//    case .lowPowerCharging:
//        BatteryIconName = "battery.100percent.bolt"
//        return .yellow
//    case .empty:
//        BatteryIconName = "battery.0percent"
//        return .red
//    case .normal:
//        BatteryIconName = "battery.100percent"
//        return .white
//    }
//}
    
struct ExtensionBatteryViewLeading: View {
    var body: some View {
        Image(systemName: BatteryManager.shared.BatteryIconName)
            .resizable()
            .scaledToFit()
            .foregroundColor(BatteryManager.shared.BatteryIconColor)
            .frame(width: 30, height: 30)
    }
}
    
struct ExtensionBatteryViewTrailing: View {
    var body: some View {
        Text("\(Int(BatteryManager.shared.currentCapacity)) %")
            .foregroundColor(BatteryManager.shared.BatteryIconColor)
            .fontWeight(.bold)
            .frame(height: 30)
    }
}



//#Preview {
//    ExtensionBatteryView()
//}
