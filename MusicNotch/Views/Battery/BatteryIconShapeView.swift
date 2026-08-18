//
//  BatteryIconShapeView.swift
//  MusicNotch
//
//  Created by Noah Johann on 02.07.26.
//

import SwiftUI

struct BatteryIconShapeView: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: width / 5)
            
            RoundedRectangle(cornerRadius: width / 17)
                .frame(width: width / 17, height: height / 2.5)
                .padding(.leading, width / 18)
        } .frame(width: width, height: height)
    }
}

#Preview {
    BatteryIconShapeView(width: 70, height: 35)
        .padding(20)
}
