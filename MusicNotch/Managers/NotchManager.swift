//
//  NotchManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import DynamicNotchKit
import SwiftUI
import Defaults
import AppKit

@MainActor @Observable
final class NotchManager {
    static let shared = NotchManager()
    
    var notchState: NotchState = .hidden
    var notchContent: NotchContent = .music
    var notchDismissed: Bool = false
    
    var notch: DynamicNotch<AnyView, AnyView, AnyView>
    
    private var openingTask: Task<Void, Never>?
    private var extensionNotchTask: Task<Void, Never>?
    private var extensionRequestCounter: Int = 0
    
    private var isHovering = false

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
            style: .notch(topCornerRadius: 25, bottomCornerRadius: 50),
            expanded: { AnyView(EmptyView()) },
            compactLeading: { AnyView(EmptyView()) },
            compactTrailing: { AnyView(EmptyView()) }
        )
    }
    
    @MainActor deinit {
        removeScrollMonitors()
    }
    
    // MARK: - Setup
    
    public func createNotch() {
        notch = DynamicNotch(
            hoverBehavior: .increaseShadow,
            style: .notch(topCornerRadius: 25, bottomCornerRadius: 50),
            expanded: { AnyView(NotchViewExpanded()) },
            compactLeading: { AnyView(NotchViewLeading()) },
            compactTrailing: { AnyView(NotchViewTrailing()) }
        )
        notch.moveToSky()
        notch.onHoverChanged = { [weak self] isHovering in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.handleHoverChange(isHovering)
            }
        }
        Task { @MainActor in
            await self.setNotchState(.closed, false)
        }
        
        Task { @MainActor in
            self.addScrollMonitors()
        }
        
        self.onHorizontalSwipe = { direction in
            guard Defaults[.enableGestures] && Defaults[.mediaGestures] else { return }
            if Defaults[.hapticFeedback] {
                let performer = NSHapticFeedbackManager.defaultPerformer
                performer.perform(.alignment, performanceTime: .default)
            }
            switch direction {
            case .left:
                MusicActions.nextTrack()
                print("next track")
            case .right:
                MusicActions.lastTrack()
                print("last track")
            default:
                break
            }
        }
        self.onVerticalSwipe = { [weak self] direction in
            guard Defaults[.enableGestures] else { return }
            guard let self else { return }
            if Defaults[.hapticFeedback] {
                let performer = NSHapticFeedbackManager.defaultPerformer
                performer.perform(.alignment, performanceTime: .default)
            }
            switch direction {
            case .up:
                Task {
                    if self.notchState == .open {
                        if MusicManager.shared.music.isPlaying == true {
                            await self.setNotchState(.compact, false)
                        } else {
                            await self.setNotchState(.closed, false)
                        }
                        print("notch close")
                    } else if self.notchState == .compact {
                        self.notchDismissed = true
                        await self.setNotchState(.transparent, false)
                        print("dismiss notch")
                    }
                }
            case .down:
                Task {
                    await self.setNotchState(.open, false)
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Hover Management

    private func handleHoverChange(_ hoverState: Bool) {
        guard self.notchContent != .locked && self.notchContent != .unlocked else { return }

        self.isHovering = hoverState
        
        if isHovering {
            if Defaults[.hapticFeedback] {
                Task { @MainActor in
                    let performer = NSHapticFeedbackManager.defaultPerformer
                    performer.perform(.alignment, performanceTime: .now)
                }
            }
            
            if Defaults[.hoverBehavior] == .musicGlance {
                if self.notchState != .compact {
                    Task { @MainActor in
                        await setNotchState(.compact, false)
                    }
                }
                self.setNotchContent(.musicGlance)
            } else if Defaults[.hoverBehavior] == .expand {
                self.openingTask?.cancel()
                
                self.openingTask = Task { @MainActor in
                    do {
                        try await Task.sleep(for: .seconds(Defaults[.openingDelay]))
                                                
                        guard self.isHovering && !Task.isCancelled else { return }
                        
                        await self.setNotchState(.open, false)
                    } catch {
                        return
                    }
                }
            }
        } else {
            self.openingTask?.cancel()
            
            if notchState == .open {
                Task {
                    if MusicManager.shared.music.isPlaying {
                        await self.setNotchState(.compact, false)
                    } else {
                        await self.setNotchState(.closed, false)
                    }
                }
            }
            if Defaults[.hoverBehavior] == .musicGlance {
                self.setNotchContent(.music)
            }
        }
        
        if Defaults[.hapticFeedback] && self.notchState == .open {
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

        guard isHovering else { return }

        let phase = event.phase
        let momentum = event.momentumPhase

        let dx = event.scrollingDeltaX
        let dy = event.scrollingDeltaY

        let inverted = event.isDirectionInvertedFromDevice

        let absX = abs(dx)
        let absY = abs(dy)
        let horizontalDominant = absX > absY

        let began = phase.contains(.began) || momentum.contains(.began)
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
    
    // MARK: - Notch control
    
    public func toggleNotch() {
        openingTask?.cancel()
        
        Task {
            if notchState == .compact {
                await setNotchState(.open, false)
                
            } else if notchState == .open {
                await setNotchState(.compact, false)
                
            } else if notchState == .closed || notchState == .transparent {
                await setNotchState(.compact, false)
            }
        }
    }
    
    public func setNotchState(_ state: NotchState, _ changeDisplay: Bool) async {        
        let prevNotchState = self.notchState
                
        if changeDisplay == true {
            await self.notch.hide()
            self.addScrollMonitors()
            self.notchContent = .music
        }
        
        switch state {
        case .open:
            notchState = .open
            MusicManager.shared.updateMusic()
            
            await self.notch.expand(on: NSScreen.selectedDisplay(.open)!)
            self.notch.moveToSky()
        case .compact:
            notchState = .compact
            MusicManager.shared.updateMusic()
            if prevNotchState == .open {
                self.setNotchContent(.music)
            }
            let screen = NSScreen.selectedDisplay(.compact)
            if screen != nil {
                await self.notch.compact(on: screen!)
            } else {
                await self.notch.transparent()
            }
            self.notch.moveToSky()
        case .closed:
            notchState = .closed
            await self.notch.close()
            guard let _ = NSScreen.selectedDisplay(.closed) else {
                await self.notch.transparent()
                return
            }
        case .transparent:
            if notchState != .closed {
                await setNotchState(.closed, false)
            }
            notchState = .transparent
            await self.notch.transparent()
        case .hidden:
            await self.notch.hide()
        }
        self.addScrollMonitors()
    }
    
    public func showExtensionNotch(type: NotchContent) {
        guard self.notchContent != .locked || type == .unlocked else { return }

        extensionRequestCounter &+= 1
        let requestToken = extensionRequestCounter

        extensionNotchTask?.cancel()
        extensionNotchTask = Task { @MainActor in
            switch type {
            case .music:
                return
            case .musicGlance:
                setNotchContent(.musicGlance)
            case .battery:
                guard Defaults[.batteryExtension] else { return }
                setNotchContent(.battery)
            case .volume:
                guard Defaults[.hudExtension] else { return }
                setNotchContent(.volume)
            case .brightness:
                guard Defaults[.hudExtension] else { return }
                setNotchContent(.brightness)
            case .bluetooth:
                guard Defaults[.bluetoothRecognition] else { return }
                setNotchContent(.bluetooth)
            case .unlocked:
                setNotchContent(.unlocked)
            case .locked:
                setNotchContent(.locked)
                if notchState == .closed || notchState == .transparent {
                    await setNotchState(.compact, false)
                }
                self.extensionNotchTask = nil
                return
            }

            if notchState == .closed || notchState == .transparent {
                await setNotchState(.compact, false)
            }

            // Wait for display duration
            try? await Task.sleep(nanoseconds: UInt64(Defaults[.displayDuration] * 1_000_000_000))

            // Only the latest request should proceed past this point
            guard requestToken == self.extensionRequestCounter, !Task.isCancelled else {
                self.extensionNotchTask = nil
                return
            }

            if MusicManager.shared.music.isPlaying {
                setNotchContent(.music)
            } else {
                if notchState != .open {
                    await setNotchState(.closed, false)
                    self.notchContent = .music
                } else {
                    setNotchContent(.music)
                }
            }

            self.extensionNotchTask = nil
        }
    }
    
    func setNotchContent(_ notchContent: NotchContent, duration: Double = 0.6) {
        withAnimation(.bouncy(duration: duration)) {
            self.notchContent = notchContent
        }
    }
}


enum NotchState {
    case open
    case compact
    case closed
    case transparent
    case hidden
}

enum NotchContent {
    case music
    case musicGlance
    case battery
    case bluetooth
    case volume
    case brightness
    case locked
    case unlocked
}
