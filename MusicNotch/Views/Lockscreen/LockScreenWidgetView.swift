//
//  LockScreenWidgetView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.09.26.
//

import SwiftUI

struct LockScreenWidgetView: View {
    @State private var gestureManager = GestureManager.shared
    
    var stackSpacing: CGFloat {
        interpolate(
            progress: gestureManager.horizontalLockSwipeValue,
            keyframes: [
                (0, 0),
                (15, 0),
                (30, 6),
                (350, 6),
                (700, 350),
            ]
        )
    }
    
    var clearTextOpacity: CGFloat {
        interpolate(
            progress: gestureManager.horizontalLockSwipeValue,
            keyframes: [
                (0, 0),
                (40, 0),
                (110, 1),
            ]
        )
    }
    
    var clearFrameScaleEffect: CGFloat {
        interpolate(
            progress: gestureManager.horizontalLockSwipeValue,
            keyframes: [
                (0, 0),
                (30, 0.8),
                (40, 1),
            ]
        )
    }
    
    var clearFrameOpacity: CGFloat {
        interpolate(
            progress: gestureManager.horizontalLockSwipeValue,
            keyframes: [
                (0, 0),
                (30, 0),
                (40, 1),
            ]
        )
    }
    
    var clearFrameSize: CGFloat {
        interpolate(
            progress: gestureManager.horizontalLockSwipeValue,
            keyframes: [
                (0, 0),
                (350, 350),
            ]
        )
    }
    
    var globalOffset: CGFloat {
        if gestureManager.horizontalLockSwipeValue < 0 {
            return gestureManager.horizontalLockSwipeValue
        } else {
            return stackSpacing / 2 + (clearFrameSize / 2)
        }
    }
    
    var globalOpacity: CGFloat {
        interpolate(
            progress: gestureManager.horizontalLockSwipeValue,
            keyframes: [
                (0, 1),
                (350, 1),
                (750, 0),
            ]
        )
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: stackSpacing) {
                LockScreenPlayingView()
                
                Text("Clear")
                    .lineLimit(1)
                    .foregroundStyle(.white.opacity(clearTextOpacity))
                    .frame(width: clearFrameSize, height: 190, alignment: .center)
                    .background {
                        if #available(macOS 26, *) {
                            GlassView(style: .clear, cornerRadius: 30)
                                .environment(\.controlActiveState, .active)
                        } else {
                            ZStack {
                                MaterialView(
                                    material: .menu,
                                    blendingMode: .behindWindow
                                )
                                
                                Rectangle()
                                    .foregroundStyle(.tint)
                                    .blendMode(.multiply)
                            }
                        }
                    }
                    .scaleEffect(clearFrameScaleEffect, anchor: .trailing)
                    .opacity(clearFrameOpacity)
            }
            .animation(.snappy(duration: 0.3), value: gestureManager.horizontalLockSwipeValue)
            .offset(x: -globalOffset)
            .opacity(globalOpacity)
            .onHover { hovering in
                print("lock hovering \(hovering)")
                WindowManager.shared.lockScreenIsHovering = hovering
                print("manager \(WindowManager.shared.lockScreenIsHovering)")
            }
        }
        .frame(width: (NSScreen.main?.frame.width ?? NSScreen.screens.first?.frame.width ?? 700), alignment: .center)
    }
}
    

@available(macOS 26, *)
#Preview {
    @Previewable @State var spacing: CGFloat = 0
    VStack {
        HStack {
            Text("\(spacing.rounded())")
            Slider(value: $spacing, in: 0...500, step: 1)
        }
        LockScreenWidgetView()
    } .frame(width: 700)
    
}

func interpolate(
    progress: CGFloat,
    keyframes: [(progress: CGFloat, value: CGFloat)]
) -> CGFloat {
    guard let first = keyframes.first else { return 0 }
    guard let last = keyframes.last else { return first.value }

    if progress <= first.progress {
        return first.value
    }

    if progress >= last.progress {
        return last.value
    }

    for i in 0..<(keyframes.count - 1) {
        let a = keyframes[i]
        let b = keyframes[i + 1]

        if progress >= a.progress && progress <= b.progress {
            let localProgress =
                (progress - a.progress) /
                (b.progress - a.progress)

            return a.value + (b.value - a.value) * localProgress
        }
    }

    return last.value
}
