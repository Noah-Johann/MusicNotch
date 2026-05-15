//
//  ScalingPlainButtonStyle.swift
//  MusicNotch
//
//  Created by Noah Johann on 15.05.26.
//

import SwiftUI

struct ScalingPlainButtonStyle: ButtonStyle {
    /// The downscaled size relative to the original size
    var downScale: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? downScale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        
    }
}
