//
//  HoverEffectButton.swift
//  MusicNotch
//
//  Created by Noah Johann on 10.01.26.
//

import SwiftUI

struct HoverEffectButton: View {
    var icon: String
    var iconColor: Color = .primary
    var iconSize: CGFloat
    var effectSize: CGFloat
    var cornerRadius: CGFloat
    @Binding var dot: Bool
    var action: () -> Void
    var contentTransition: ContentTransition = .symbolEffect;
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .frame(width: effectSize, height: effectSize)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isHovering ? Color.gray.opacity(0.2) : .clear)
                        .frame(width: effectSize, height: effectSize)
                        .overlay {
                            VStack (spacing: 3) {
                                Image(systemName: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(iconColor)
                                    .contentTransition(contentTransition)
                                    .frame(width: iconSize, height: iconSize)
                                if dot {
                                    Circle()
                                        .fill(iconColor)
                                        .frame(width: 3, height: 3)
                                }
                            } .animation(.spring(response: 0.3, dampingFraction: 0.4), value: dot)
                        }
                }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.smooth(duration: 0.3)) {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    @Previewable @State var icon: Bool = false
    HoverEffectButton(icon: icon ? "play.fill" : "pause.fill", iconSize: 60, effectSize: 100, cornerRadius: 30, dot: $icon) {
        icon.toggle()
    }
        .padding(20)
}
