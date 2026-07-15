//
//  NotchBatteryView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI
    
struct NotchBatteryViewLeading: View {
    @State var batteryManager = BatteryManager.shared
    
    var infoText: String {
        switch batteryManager.updateType {
            case .lowPowerMode: return "Low Power"
            case .lowBattery: return "Low Battery"
            case .charging: return "Charging"
        }
    }
    
    var body: some View {
        HStack {
            Text(infoText)
                .font(.system(size: 12))
                .padding(.leading, 4)
            Spacer()
        } .frame(width: 90)
    }
}
    
struct NotchBatteryViewTrailing: View {
    @State var batteryManager = BatteryManager.shared
    
    var computedPercent: CGFloat {
        return batteryManager.currentCapacity / 100
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack(alignment: .bottom, spacing: 0) {
                Text("\(Int(batteryManager.currentCapacity))")
                    .font(.system(size: 12))
                Text("%")
                    .font(.system(size: 11))
            } .foregroundColor(batteryManager.batteryIconColor)
            
            BatteryIconView(width: 26, iconColor: batteryManager.batteryIconColor, percent: batteryManager.currentCapacity / 100)
        }
        .padding(.trailing, 4)
        .frame(width: 90)
    }
}

#Preview {
    HStack {
        NotchBatteryViewLeading()
            .background(Color.red)
        NotchBatteryViewTrailing()
            .background(Color.blue)
    }
    .padding()
}

