//
//  NotchMangager.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import Foundation
import DynamicNotchKit
import SwiftUI
import Defaults
import AppKit

@MainActor
final class NotchManager {
    
    @Published var notchState: NotchState = .hidden
    
    static let shared = NotchManager()
    
    let notch: DynamicNotch<NotchViewExpanded, NotchViewLeading, NotchViewTrailing>
    
    private var openingTask: Task<Void, Never>?
    private var hapticTask: Task<Void, Never>?
    private var expandTask: Task<Void, Never>?
    private var extensionNotchTask: Task<Void, Never>?
    private var extensionRequestCounter: Int = 0
    
    private var isCurrentlyHovering = false

    private var localScrollMonitor: Any?
    private var globalScrollMonitor: Any?
    private weak var observedWindow: NSWindow?

    private var isHorizontalGestureActive = false
    private var isVerticalGestureActive = false

    var onHorizontalSwipe: ((SwipeDirection) -> Void)?
    var onVerticalSwipe: ((SwipeDirection) -> Void)?

    enum SwipeDirection { case left, right, up, down }
    
    private init() {
        notch = DynamicNotch(
           hoverBehavior: .increaseShadow,
           style: .notch,
           expanded: { NotchViewExpanded() },
           compactLeading: { NotchViewLeading() },
           compactTrailing: { NotchViewTrailing() }
       ).moveToSky()
        notch.onHoverChanged = { [weak self] isHovering in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.handleHoverChange(isHovering)
            }
        }
        
        Task { @MainActor in
            self.addScrollMonitors()
        }
        
        self.onHorizontalSwipe = { direction in
            if Defaults[.hapticFeedback] {
                let performer = NSHapticFeedbackManager.defaultPerformer
                performer.perform(.alignment, performanceTime: .default)
            }
            switch direction {
            case .left:
                spotifyNextTrack()
                print("next track")
            case .right:
                spotifyLastTrack()
                print("last track")
            default:
                break
            }
        }
        self.onVerticalSwipe = { [weak self] direction in
            guard let self else { return }
            if Defaults[.hapticFeedback] {
                let performer = NSHapticFeedbackManager.defaultPerformer
                performer.perform(.alignment, performanceTime: .default)
            }
            switch direction {
            case .up:
                Task {
                    await self.setNotchContent(.closed, false)
                    print("notch close")
                }
            case .down:
                Task {
                    await self.setNotchContent(.openWithoutHover, false)
                    print("notch open")
                }
            default:
                break
            }
        }
    }
    
    @MainActor deinit {
        removeScrollMonitors()
    }
    
    // MARK: - Hover Management

    private func handleHoverChange(_ isHovering: Bool) {
        self.isCurrentlyHovering = isHovering
        
       // guard Defaults[.openNotchOnHover] else { return }
        if isHovering {
            // Cancel any existing tasks
            guard Defaults[.openNotchOnHover] else { return }

            self.openingTask?.cancel()
            self.hapticTask?.cancel()
            
            guard NotchContentState.shared.notchContent != .locked && NotchContentState.shared.notchContent != .unlocked else { return }
            
            self.openingTask = Task { @MainActor in
                // Wait for the opening delay
                do {
                    try await Task.sleep(nanoseconds: UInt64(Defaults[.openingDelay] * 1_000_000_000))
                } catch {
                    return
                }
                
                guard self.isCurrentlyHovering && !Task.isCancelled else {
                    return
                }
                
                await self.setNotchContent(.open, false)
                
                if Defaults[.hapticFeedback] && Defaults[.openingDelay] != 0 {
                    self.hapticTask = Task { @MainActor in
                        
                        guard !Task.isCancelled else { return }
                        
                        let performer = NSHapticFeedbackManager.defaultPerformer
                        performer.perform(.alignment, performanceTime: .now)
                    }
                }
            }
        } else {
            self.openingTask?.cancel()
            self.hapticTask?.cancel()
            self.expandTask?.cancel()
            
            if notchState == .open || self.expandTask != nil {
                Task {
                    await self.setNotchContent(.closed, false)
                }
            }
        }
        
        if Defaults[.hapticFeedback] {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
    
    // MARK: - Gesture monitor setup
    private func addScrollMonitors() {
        guard let window = notch.windowController?.window else { return }
        if observedWindow === window { return }

        removeScrollMonitors()

        observedWindow = window

        localScrollMonitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.handleScrollEvent(event)
            return event
        }

        globalScrollMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
            self?.handleScrollEvent(event)
        }
    }

    private func removeScrollMonitors() {
        if let localScrollMonitor { NSEvent.removeMonitor(localScrollMonitor) }
        if let globalScrollMonitor { NSEvent.removeMonitor(globalScrollMonitor) }
        localScrollMonitor = nil
        globalScrollMonitor = nil
        observedWindow = nil
        isHorizontalGestureActive = false
        isVerticalGestureActive = false
    }

    private func handleScrollEvent(_ event: NSEvent) {

        guard isCurrentlyHovering else { return }

        let phase = event.phase
        let momentum = event.momentumPhase

        let dx = event.scrollingDeltaX
        let dy = event.scrollingDeltaY

        let inverted = event.isDirectionInvertedFromDevice

        let absX = abs(dx)
        let absY = abs(dy)
        let horizontalDominant = absX > absY

        let began = phase.contains(.began) || momentum.contains(.began)
    //    let ended = phase.contains(.ended) || phase.contains(.cancelled) || momentum.contains(.ended)
        let ended = momentum.contains(.ended)

        if began {
            if horizontalDominant {
                if !isHorizontalGestureActive {
                    isHorizontalGestureActive = true
                    let direction: SwipeDirection = {
                        if inverted {
                            return dx > 0 ? .left : .right
                        } else {
                            return dx > 0 ? .right : .left
                        }
                    }()
                    onHorizontalSwipe?(direction)
                }
                isVerticalGestureActive = false
            } else {
                if !isVerticalGestureActive {
                    isVerticalGestureActive = true
                    let direction: SwipeDirection = {
                        if inverted {
                            return dy > 0 ? .down : .up
                        } else {
                            return dy > 0 ? .up : .down
                        }
                    }()
                    onVerticalSwipe?(direction)
                }
                isHorizontalGestureActive = false
            }
        }

        if ended {
            isHorizontalGestureActive = false
            isVerticalGestureActive = false
        }
    }
    
    public func changeNotch() {
        openingTask?.cancel()
        hapticTask?.cancel()
        expandTask?.cancel()
        
        Task {
            if notchState == .closed {
                await setNotchContent(.openWithoutHover, false)
                
            } else if notchState == .open {
                await setNotchContent(.closed, false)
                
            } else if notchState == .hidden {
                await setNotchContent(.openWithoutHover, false)
            }
        }
    }
    
    public func setNotchContent(_ content: NotchState, _ changeDisplay: Bool) async {
        SpotifyManager.shared.updateInfo()
        
        let prevNotchState = self.notchState
                
        if changeDisplay == true {
            await self.notch.hide()
            self.addScrollMonitors()
            NotchContentState.shared.notchContent = .music
        }
        
        switch content {
            
        case .open:
            notchState = .open
            SpotifyManager.shared.updateInfo()
            
            // Track the expand operation so we can cancel it if needed
            self.expandTask = Task {
                // Check one more time if we should still expand
                guard self.isCurrentlyHovering && !Task.isCancelled else {
                    // User stopped hovering, go to compact instead
                    await self.setNotchContent(.closed, false)
                    self.expandTask = nil
                    return
                }
                
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .music
                }
                
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        if Defaults[.noNotchScreenHide] {
                            await self.notch.hide()
          //                  self.addScrollMonitors()
                        } else {
                            await self.notch.expand(on: NSScreen.screens.first!)
         //                   self.addScrollMonitors()
                            self.notch.moveToSky()
                        }
                        return
                    }
                    await self.notch.expand(on: notchScreen)
        //            self.addScrollMonitors()
                    self.notch.moveToSky()
                } else {
                    await self.notch.expand(on: NSScreen.screens.first!)
        //            self.addScrollMonitors()
                    self.notch.moveToSky()
                }
                
                // Clear the task reference when completed
                self.expandTask = nil
            }
            
        case .openWithoutHover:
            notchState = .open
            SpotifyManager.shared.updateInfo()
            
            // Track the expand operation so we can cancel it if needed
            self.expandTask = Task {
                
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        if Defaults[.noNotchScreenHide] {
                            await self.notch.hide()
          //                  self.addScrollMonitors()
                        } else {
                            await self.notch.expand(on: NSScreen.screens.first!)
         //                   self.addScrollMonitors()
                            self.notch.moveToSky()
                        }
                        return
                    }
                    await self.notch.expand(on: notchScreen)
        //            self.addScrollMonitors()
                    self.notch.moveToSky()
                } else {
                    await self.notch.expand(on: NSScreen.screens.first!)
        //            self.addScrollMonitors()
                    self.notch.moveToSky()
                }
                
                // Clear the task reference when completed
                self.expandTask = nil
            }
            
        case .closed:
            notchState = .closed
            
            if prevNotchState == .open {
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .music
                }
            }
            
            if Defaults[.notchDisplay] == true {
                guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                    if Defaults[.noNotchScreenHide] && Defaults[.notchDisplay] {
                        await self.notch.hide()
       //                 self.addScrollMonitors()
                    } else {
                        await self.notch.compact(on: NSScreen.screens.first!)
       //                 self.addScrollMonitors()
                        self.notch.moveToSky()
                    }
                    return
                }
                await self.notch.compact(on: notchScreen)
      //          self.addScrollMonitors()
                self.notch.moveToSky()
            } else {
                await self.notch.compact(on: NSScreen.screens.first!)
     //           self.addScrollMonitors()
                self.notch.moveToSky()
            }
            
        case .hidden:
            notchState = .hidden
            if Defaults[.mainDisplay] == true && Defaults[.disableNotchOnHide] == true {
                await self.notch.hide()
    //            self.addScrollMonitors()
            } else if Defaults[.mainDisplay] == true && Defaults[.disableNotchOnHide] == false {
                await self.notch.compact(on: NSScreen.screens.first!)
    //            self.addScrollMonitors()
                self.notch.moveToSky()
            }
            
            if Defaults[.notchDisplay] == true {
                guard NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) != nil else {
                    if Defaults[.noNotchScreenHide] {
                        await self.notch.hide()
      //                  self.addScrollMonitors()
                    } else {
                        await self.notch.close()
       //                 self.addScrollMonitors()
                    }
                    return
                }
                await self.notch.close()
  //              self.addScrollMonitors()
            }
        }
        self.addScrollMonitors()
    }
    
    public func showExtensionNotch(type: NotchContent) {
        guard NotchContentState.shared.notchContent != .locked || type == .unlocked else { return }

        extensionRequestCounter &+= 1
        let requestToken = extensionRequestCounter

        extensionNotchTask?.cancel()
        extensionNotchTask = Task { @MainActor in
            switch type {
            case .music:
                return
            case .battery:
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .battery
                }
            case .volume:
                guard Defaults[.hudExtension] else { return }
                
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .volume
                }
            case .brightness:
                guard Defaults[.hudExtension] else { return }
                
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .brightness
                }
            case .locked:
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .locked
                }
                if notchState == .hidden {
                    await setNotchContent(.closed, false)
                }
                self.extensionNotchTask = nil
                
                return
            case .unlocked:
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .unlocked
                }
            }

            if notchState == .hidden {
                await setNotchContent(.closed, false)
            }

            // Wait for display duration
            try? await Task.sleep(nanoseconds: UInt64(Defaults[.displayDuration] * 1_000_000_000))

            // Only the latest request should proceed past this point
            guard requestToken == self.extensionRequestCounter, !Task.isCancelled else {
                self.extensionNotchTask = nil
                return
            }

            if SpotifyManager.shared.isPlaying {
                withAnimation(.bouncy(duration: 0.6)) {
                    NotchContentState.shared.notchContent = .music
                }
            } else {
                if notchState != .open {
                    await setNotchContent(.hidden, false)
                    NotchContentState.shared.notchContent = .music
                } else {
                    withAnimation(.bouncy(duration: 0.6)) {
                        NotchContentState.shared.notchContent = .music
                    }
                }
            }

            self.extensionNotchTask = nil
        }
    }
}


enum NotchState {
    case open
    case openWithoutHover
    case closed
    case hidden
}

enum NotchContent {
    case music
    case battery
    case volume
    case brightness
    case locked
    case unlocked
}

