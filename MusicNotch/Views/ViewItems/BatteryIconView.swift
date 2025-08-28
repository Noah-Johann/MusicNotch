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
    
//    var cornerRadius: CGFloat {
//        iconWidth / 18.5185185185
//    }
    
    var body: some View {
        let cornerRadius: CGFloat = iconWidth / 18.5185185185
        let fillWidth: CGFloat = iconWidth / 144.2275362319
        let fillHeight: CGFloat = iconWidth / 3.8461538462
        let fillLeadingInset: CGFloat = iconWidth/10.4166666667
        let boltWidth: CGFloat = iconWidth * 0.88
        let boltHeight: CGFloat = iconWidth * 0.6
        
        ZStack (alignment: .leading) {
            Image(systemName: "battery.0percent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.white.opacity(0.5))
            
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(batteryManager.batteryIconColor)
                .frame(
                    width: fillWidth * max(5, min(100, batteryManager.currentCapacity)),
                    height: fillHeight,
                )
                .padding(.leading, fillLeadingInset)
            
            
            if batteryManager.isCharging {
                ZStack (alignment: .center) {
                    ZStack {
                        Image(systemName: "bolt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.black)
                            .frame(height: boltHeight)
                            .overlay(
                                Image(systemName: "bolt.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(Color.white.opacity(0.8))
                                    .padding(1)
                            )
                    }
                } .frame(width: boltWidth)
            }
        }
        .frame(width: iconWidth)
    }
}

#Preview {
    BatteryIconView(iconWidth: 30)
        .padding()
}
