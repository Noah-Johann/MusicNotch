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
    private var localScrollMonitor: Any?
    
    var swipeDirection: SwipeDirection = .vertical
    var horizontalType: HorizontalType = .right
    var verticalType: VerticalType = .up
    var scrollTarget: ScrollTarget = .lock
        
    
    // Notch
    private var horizontalSwipeDelta: CGFloat = 0       // positive = +x, negative = -x
    private var verticalSwipeDelta: CGFloat = 0         // positive = -y, negative = +y
    var horizontalNotchSwipeThreshold: CGFloat = 200
    var verticalNotchSwipeThreshold: CGFloat = 200
    private var horizontalNotchThresholdCrossed: Bool = false
    private var verticalNotchThresholdCrossed: Bool = false
    
    // LockScreen
    var horizontalLockSwipeValue: CGFloat = 0   // positive = left, negative = right
    var horizontalLockKeepThreshold: CGFloat = 90      // Threshold for keeping delete option on submit
    var horizontalLockDeleteThreshold: CGFloat = 300    // Threshold for hiding widget on submit
    var horizontalLockRightMax: CGFloat = 25
    private var horizontalLockDeleteOpen: CGFloat = 110
    private var horizontalLockKeepThresholdCrossed: Bool = false
    private var horizontalLockDeleteThresholdCrossed: Bool = false
    
    public func setLockScreenDeleteOpen() {
        horizontalLockSwipeValue = horizontalLockDeleteOpen
    }
        
    
    var horizontalNotchGestureRelative: CGFloat {
        if horizontalSwipeDelta > 0 {
            horizontalType = .right
        } else if horizontalSwipeDelta < 0 {
            horizontalType = .left
        }
        
        let absDelta = abs(horizontalSwipeDelta)
        guard absDelta > 0 else { return 0 }
        let relative = absDelta / horizontalNotchSwipeThreshold
        if relative < 0.1 {
            return 0
        }
        if relative > 1 {
            return 1
        }
        return relative
    }
    
    var verticalNotchGestureRelative: CGFloat {
        if verticalSwipeDelta > 0 {
            verticalType = .down
        } else if verticalSwipeDelta < 0 {
            verticalType = .up
        }
        
        let absDelta = abs(verticalSwipeDelta)
        guard absDelta > 0 else { return 0 }
        let relative = absDelta / verticalNotchSwipeThreshold
        if relative < 0.1 {
            return 0
        }
        if relative > 1 {
            return 1
        }
        return (relative * 100).rounded() / 100
    }
    
    enum SwipeDirection { case horizontal, vertical }
    enum HorizontalType { case left, right }
    enum VerticalType { case up, down }
    enum ScrollTarget { case notch, lock }
    
    deinit {
        removeScrollMonitors()
    }
    
    private func handleScrollSubmit() {
        print("Scroll target \(scrollTarget)")
        print("value \(horizontalLockSwipeValue)")
        switch swipeDirection {
            case .horizontal:
                switch scrollTarget {
                    case .notch:
                        guard Defaults[.mediaGestures] else { return }
                        guard abs(horizontalSwipeDelta) > horizontalNotchSwipeThreshold else { return }
                        if horizontalSwipeDelta > 0 {
                            MusicActions.nextTrack()
                        } else {
                            MusicActions.lastTrack()
                        }
                    case .lock:
                        if horizontalLockSwipeValue > horizontalLockDeleteThreshold {
                            WindowManager.shared.hideLockScreen()
                            horizontalLockSwipeValue = 0
                        } else if horizontalLockSwipeValue > horizontalLockKeepThreshold * 0.8 {
                            horizontalLockSwipeValue = horizontalLockDeleteOpen
                        } else {
                            horizontalLockSwipeValue = 0
                        }
                }
            case .vertical:
                guard Defaults[.enableGestures] else { return }
                guard abs(verticalSwipeDelta) > verticalNotchSwipeThreshold else { return }
                if verticalSwipeDelta < 0 {
                    Task { @MainActor in
                        if NotchManager.shared.notchState == .open {
                            if MusicManager.shared.music.isPlaying == true {
                                await NotchManager.shared.setNotchState(.compact)
                            } else {
                                await NotchManager.shared.setNotchState(.closed)
                            }
                        } else if NotchManager.shared.notchState == .compact {
                            NotchManager.shared.notchDismissed = true
                            await NotchManager.shared.setNotchState(.transparent)
                        }
                    }
                } else {
                    Task {
                        await NotchManager.shared.setNotchState(.open)
                    }
                }
        }
        
    }
    
    private func handleScrollThresholdCross(direction: SwipeDirection) {
        switch direction {
            case .horizontal: horizontalNotchThresholdCrossed = true
            case .vertical: verticalNotchThresholdCrossed = true
        }
        if Defaults[.hapticFeedback] {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
    
    public func addScrollMonitors() {
        removeScrollMonitors()
        
        localScrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.handleScrollEvent(event)
            return event
        }
        
        globalScrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.handleScrollEvent(event)
        }
    }
    
    public func removeScrollMonitors() {
        if let localScrollMonitor { NSEvent.removeMonitor(localScrollMonitor) }
        if let globalScrollMonitor { NSEvent.removeMonitor(globalScrollMonitor) }
        localScrollMonitor = nil
        globalScrollMonitor = nil
        
    }
    
    private func handleScrollEvent(_ event: NSEvent) {
        guard NotchManager.shared.isHovering || WindowManager.shared.lockScreenIsHovering else { return }
        guard event.hasPreciseScrollingDeltas else { return }
        
        let phase = event.phase
        
        let dx = event.scrollingDeltaX
        let dy = event.scrollingDeltaY
        
        if phase.contains(.began) {
            if NotchManager.shared.isHovering {
                scrollTarget = .notch
            } else if WindowManager.shared.lockScreenIsHovering {
                scrollTarget = .lock
            }
            
            if abs(dx) > abs(dy) {
                swipeDirection = .horizontal
            } else {
                swipeDirection = .vertical
            }
        } else if phase.contains(.changed) {
            if swipeDirection == .horizontal {
                switch scrollTarget {
                    case .notch:
                        if abs(self.horizontalSwipeDelta) + dx > horizontalNotchSwipeThreshold * 1.1 {
                            self.horizontalSwipeDelta = horizontalNotchSwipeThreshold * 1.1 * (dx > 0 ? 1 : -1)
                        } else {
                            self.horizontalSwipeDelta += dx
                        }
                        self.swipeDirection = .horizontal
                        
                        let absDelta = abs(horizontalSwipeDelta)
                        if absDelta > horizontalNotchSwipeThreshold && horizontalNotchThresholdCrossed == false {
                            handleScrollThresholdCross(direction: .horizontal)
                        }
                        if absDelta < horizontalNotchSwipeThreshold * 0.8 && horizontalNotchThresholdCrossed == true {
                            horizontalNotchThresholdCrossed = false
                        }
                    case .lock:
                        let lockDX = dx * -1
                        if lockDX > 0 {
                            horizontalLockSwipeValue += lockDX
                        } else {
                            if horizontalLockSwipeValue < 0 && abs(horizontalLockSwipeValue) + abs(lockDX) > horizontalLockRightMax {
                                horizontalLockSwipeValue = -horizontalLockRightMax
                            } else {
                                horizontalLockSwipeValue += lockDX
                            }
                        }
                }
            } else {
                guard NotchManager.shared.isHovering else { return }
                
                if self.verticalSwipeDelta + dy > verticalNotchSwipeThreshold * 1.1 {
                    self.verticalSwipeDelta = verticalNotchSwipeThreshold * 1.1
                } else {
                    self.verticalSwipeDelta += dy
                }
                self.swipeDirection = .vertical
                
                let absDelta = abs(verticalSwipeDelta)
                if absDelta > verticalNotchSwipeThreshold && verticalNotchThresholdCrossed == false {
                    handleScrollThresholdCross(direction: .vertical)
                }
                if absDelta < verticalNotchSwipeThreshold * 0.8 && verticalNotchThresholdCrossed == true {
                    verticalNotchThresholdCrossed = false
                }
            }
        } else if phase.contains(.ended) || phase.contains(.cancelled) {
            if phase.contains(.ended) {
                handleScrollSubmit()
            }
            if scrollTarget == .notch {
                verticalSwipeDelta = 0
                horizontalSwipeDelta = 0
                horizontalNotchThresholdCrossed = false
                verticalNotchThresholdCrossed = false
            }
        }
    }

}
