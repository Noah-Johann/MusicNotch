//
//  GestureManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 01.08.26.
//

import AppKit
import Defaults

@Observable
class GestureManager {
    static var shared = GestureManager()
    
    private var globalScrollMonitor: Any?
    
    var horizontalSwipeDelta: CGFloat = 0  // positive = +x, negative = -x
    var verticalSwipeDelta: CGFloat = 0    // positive = -y, negative = +y
    
    var horizontalSwipeThreshold: CGFloat = 200
    var verticalSwipeThreshold: CGFloat = 200
    
    var swipeDirection: SwipeDirection = .vertical
    
    enum SwipeDirection { case horizontal, vertical }
    
    deinit {
        removeScrollMonitors()
    }
    
    private func handleScrollSubmit() {
        switch swipeDirection {
            case .horizontal:
                guard Defaults[.mediaGestures] else { return }
                guard abs(horizontalSwipeDelta) > horizontalSwipeThreshold else { return }
                if horizontalSwipeDelta > 0 {
                    MusicActions.nextTrack()
                } else {
                    MusicActions.lastTrack()
                }
            case .vertical:
                guard Defaults[.enableGestures] else { return }
                guard abs(verticalSwipeDelta) > verticalSwipeThreshold else { return }
                if verticalSwipeDelta < 0 {
                    Task { @MainActor in
                        if NotchManager.shared.notchState == .open {
                            if MusicManager.shared.music.isPlaying == true {
                                await NotchManager.shared.setNotchState(.compact)
                            } else {
                                await NotchManager.shared.setNotchState(.closed)
                            }
                            print("notch close")
                        } else if NotchManager.shared.notchState == .compact {
                            NotchManager.shared.notchDismissed = true
                            await NotchManager.shared.setNotchState(.transparent)
                            print("dismiss notch")
                        }
                    }
                } else {
                    Task {
                        await NotchManager.shared.setNotchState(.open)
                    }
                }
        }
        
    }
    
    private func handleScrollThresholdCross() {
        if Defaults[.hapticFeedback] {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
    
    public func addScrollMonitors() {
        removeScrollMonitors()
        
        globalScrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.handleScrollEvent(event)
        }
    }
    
    public func removeScrollMonitors() {
        if let globalScrollMonitor { NSEvent.removeMonitor(globalScrollMonitor) }
        globalScrollMonitor = nil
    }
    
    @MainActor private func handleScrollEvent(_ event: NSEvent) {
        guard NotchManager.shared.isHovering else { return }
        guard event.hasPreciseScrollingDeltas else { return }
        
        let phase = event.phase
        
        let dx = event.scrollingDeltaX
        let dy = event.scrollingDeltaY
        
        if phase.contains(.began) {
            if abs(dx) > abs(dy) {
                swipeDirection = .horizontal
            } else {
                swipeDirection = .vertical
            }
            print("\(dx), \(dy)")
        } else if phase.contains(.changed) {
            if swipeDirection == .horizontal {
                self.horizontalSwipeDelta += dx
             //   print("horizontal\(horizontalSwipeDelta)")
                self.swipeDirection = .horizontal
//                if abs(horizontalSwipeDelta) > horizontalSwipeThreshold {
//                    handleScrollThresholdCross()
//                }
            } else {
                self.verticalSwipeDelta += dy
             //   print("vertical \(verticalSwipeDelta)")
                self.swipeDirection = .vertical
//                if abs(verticalSwipeDelta) > verticalSwipeThreshold {
//                    handleScrollThresholdCross()
//                }
            }
        } else if phase.contains(.ended) {
            print("Scroll ended")
            handleScrollSubmit()
            verticalSwipeDelta = 0
            horizontalSwipeDelta = 0
        }
    }

}
