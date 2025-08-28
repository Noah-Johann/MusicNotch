//
//  BatteryIconView.swift
//  MusicNotch
//
//  Created by Noah Johann on 28.08.25.
//

import SwiftUI

struct BatteryIconView: View {
    @ObservedObject var batteryManager = BatteryManager.shared
    
    var iconWidth: CGFloat
    
    var body: some View {
        ZStack (alignment: .leading) {
            Image(systemName: "battery.0percent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.white.opacity(0.5))
            
            
            RoundedRectangle(cornerRadius: iconWidth / 18.5185185185)
                .fill(batteryManager.batteryIconColor)
                .frame(
                    width: CGFloat(iconWidth / 144.2275362319 * batteryManager.currentCapacity),
                    height: iconWidth / 3.8461538462,
                )
                .padding(.leading, iconWidth/10.4166666667)
            
            
            if batteryManager.isCharging {
                ZStack (alignment: .center) {
                    ZStack {
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.black)
                            .frame(height: iconWidth * 0.6)
                            .overlay(
                                Image(systemName: "bolt.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color.white.opacity(0.8))
                                    .padding(1)
                            )
                    }
                } .frame(width: iconWidth * 0.88)
            }
        }
        .frame(width: iconWidth)
    }
}

#Preview {
    BatteryIconView(iconWidth: 30)
        .padding()
}
