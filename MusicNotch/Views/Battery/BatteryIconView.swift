//
//  BatteryIconView.swift
//  MusicNotch
//
//  Created by Noah Johann on 02.07.26.
//

import SwiftUI

struct BatteryIconView: View {
    var width: CGFloat
    var iconColor: Color
    var percent: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundStyle(iconColor.opacity(0.3))
            Rectangle()
                .frame(width: width * percent)
                .foregroundStyle(iconColor.gradient)
            
        }
        .mask {
            BatteryIconShapeView(width: width, height: width / 2.3)
        }
        .frame(width: width, height: width / 2.3)
    }
}

#Preview {
    BatteryIconView(width: 55, iconColor: .green, percent: 0.9)
        .padding(20)
}
