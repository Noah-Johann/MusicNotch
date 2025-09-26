//
//  HudSlider.swift
//  MusicNotch
//
//  Created by Noah Johann on 12.09.25.
//

import SwiftUI
import Defaults

struct HudSlider: View {
    @Binding var value: CGFloat
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    
    let isExpanded: Bool
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.tertiary)
                    Capsule()
                        .fill(
                            Defaults[.gradientHudSlider] ?
                                AnyShapeStyle(LinearGradient(
                                    colors: Defaults[.accentColorHudSlider] ?
                                        [Color.accentColor, Color.accentColor.ensureMinimumBrightness(factor: 0.2)] :
                                        [Color.white, Color.white.opacity(0.2)],
                                    startPoint: .trailing,
                                    endPoint: .leading
                                )) :
                                AnyShapeStyle(Defaults[.accentColorHudSlider] ? Color.accentColor : Color.white)
                        )
                        .frame(width: max(0, min(geo.size.width * value, geo.size.width)))
                        .shadow(color: Defaults[.gradientHudSlider] ?
                            (Defaults[.accentColorHudSlider] ?
                                Color.accentColor.ensureMinimumBrightness(factor: 0.7) :
                                Color.white) :
                            Color.clear,
                            radius: 7, x: 3)
                        .opacity(value.isZero ? 0 : 1)
                }
//                .gesture(
//                    DragGesture(minimumDistance: 0)
//                        .onChanged { gesture in
//                            withAnimation(.smooth(duration: 0.3)) {
//                                isDragging = true
//                                updateValue(gesture: gesture, in: geo)
//                            }
//                        }
//                        .onEnded { _ in
//                            withAnimation(.smooth(duration: 0.3)) {
//                                isDragging = false
//                            }
//                        }
//                )
            }
            .frame(height: isExpanded ? 7 : 5)
        }
    }
    
    private func updateValue(gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let dragPosition = gesture.location.x
        let newValue = dragPosition / geometry.size.width
        
        value = max(0, min(newValue, 1))
    }
}

#Preview {
    @Previewable @State var volume: CGFloat = 0.5
    HudSlider(value: $volume, isExpanded: false)
        .frame(width: 200)
        .padding(30)
}
