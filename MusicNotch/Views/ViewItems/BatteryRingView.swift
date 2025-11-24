//
//  BatteryRingView.swift
//  MusicNotch
//
//  Created by Noah Johann on 24.11.25.
//

import SwiftUI

struct BatteryRingView: View {
    @ObservedObject private var volumeManager = VolumeManager.shared
    
    
    var body: some View {
        
        ZStack {
            Circle()
                .stroke(ringColor(percent: volumeManager.deviceBattery).opacity(0.3), lineWidth: 2.5)
            
            Circle()
                .trim(from: 0, to: volumeManager.deviceBattery / 100)
                .stroke(ringColor(percent: volumeManager.deviceBattery),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        } .frame(width: 17, height: 17)
    }
    
    private func ringColor(percent: CGFloat) -> Color {
        if percent < 20 {
            return .red
        } else {
            return .green
        }
    }
}

#Preview {
    BatteryRingView()
        .padding()
}
