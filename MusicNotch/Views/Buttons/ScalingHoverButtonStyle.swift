//
//  ScalingHoverButtonStyle.swift
//  MusicNotch
//
//  Created by Noah Johann on 13.06.26.
//

import SwiftUI

struct ScalingHoverButtonStyle: ButtonStyle {
    /// The downscaled size relative to the original size
    var downScale: CGFloat
    
    /// The size of the hover background
    var effectSize: CGFloat
    
    var cornerRadius: CGFloat = 17
    
    @State private var isHovering: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .frame(width: effectSize, height: effectSize)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isHovering ? Color.gray.opacity(0.2) : .clear)
                    .frame(width: effectSize, height: effectSize)
                    .overlay {
                        configuration.label
                    }
                    .scaleEffect(configuration.isPressed ? downScale : 1.0)
            }
            .onHover { hovering in
                withAnimation(.smooth(duration: 0.3)) {
                    isHovering = hovering
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
