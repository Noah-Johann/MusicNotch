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

@Observable
final class NotchManager {
    static let shared = NotchManager()
        
    var notchState: NotchState = .hidden
    var notchContent: NotchContent = .music
    var notchDismissed: Bool = false
    
    var notch: DynamicNotch<NotchViewExpanded, NotchViewLeading, NotchViewTrailing>?
    
    private var openingTask: Task<Void, Never>?
    private var extensionNotchTask: Task<Void, Never>?
    private var extensionRequestCounter: Int = 0
    
    var isHovering = false
    
//    @MainActor deinit {
//        removeScrollMonitors()
//    }
    
    // MARK: - Setup
    
    @MainActor public func createNotch() {
        notch = nil
        notch = DynamicNotch(
            hoverBehavior: .increaseShadow,
            style: .auto,
            expanded: { NotchViewExpanded() },
            compactLeading: { NotchViewLeading() },
            compactTrailing: { NotchViewTrailing() }
        )
        guard let notch = notch else { return }
        notch.topNotchSafeAreaInset = 15
        notch.bottomNotchSafeAreaInset = 25
        notch.verticalIslandSafeAreaInset = 25
        notch.horizontalIslandSafeAreaInset = 25
        notch.moveToSky()
        notch.onHoverChanged = { [weak self] isHovering in
            guard let self = self else { return }
            
            Task {
                self.handleHoverChange(isHovering)
            }
        }
        Task {
            await self.setNotchState(.closed)
        }
        
        GestureManager.shared.addScrollMonitors()
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
                        await setNotchState(.compact)
                    }
                }
                self.setNotchContent(.musicGlance)
            } else if Defaults[.hoverBehavior] == .expand {
                self.openingTask?.cancel()
                
                self.openingTask = Task { @MainActor in
                    do {
                        try await Task.sleep(for: .seconds(Defaults[.openingDelay]))
                        
                        guard self.isHovering && !Task.isCancelled else { return }
                        
                        await self.setNotchState(.open)
                    } catch {
                        return
                    }
                }
            }
        } else {
            self.openingTask?.cancel()
            
            if notchState == .open {
                Task {
                    if await MusicManager.shared.music.isPlaying && HideManager.shared.isFullScreen == false {
                        await self.setNotchState(.compact)
                    } else {
                        await self.setNotchState(.closed)
                    }
                }
            }
            if Defaults[.hoverBehavior] == .musicGlance {
                Task {
                    if HideManager.shared.isFullScreen {
                        await self.setNotchState(.closed)
                    }
                    self.setNotchContent(.music)
                }
            }
        }
        
        if Defaults[.hapticFeedback] && self.notchState == .open {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
    
    
    // MARK: - Notch control
    
    public func toggleNotch() async {
        openingTask?.cancel()
        
        if notchState == .compact {
            await setNotchState(.open)
            
        } else if notchState == .open {
            if HideManager.shared.isFullScreen {
                await setNotchState(.closed)
            } else {
                await setNotchState(.compact)
            }
            
        } else if notchState == .closed || notchState == .transparent {
            if HideManager.shared.isFullScreen {
                await setNotchState(.open)
            } else {
                await setNotchState(.compact)
            }
        }
    }
    
    public func toggleMusicGlance() async {
        if notchContent == .musicGlance {
            setNotchContent(.music)
        } else {
            setNotchContent(.musicGlance)
        }
    }
    
    @MainActor public func setNotchState(_ state: NotchState, changeDisplay: Bool = false) async {
        guard let notch = notch else { return }
        let prevNotchState = self.notchState
                
        if changeDisplay == true {
            await notch.hide()
            GestureManager.shared.addScrollMonitors()
            self.notchContent = .music
        }
        
        switch state {
        case .open:
            notchState = .open
            MusicManager.shared.refreshMusic()
            
            await notch.expand(on: NSScreen.selectedDisplay(.open)!)
            notch.moveToSky()
        case .compact:
            notchState = .compact
            MusicManager.shared.refreshMusic()
            if prevNotchState == .open {
                self.setNotchContent(.music)
            }
            let screen = NSScreen.selectedDisplay(.compact)
            if screen != nil {
                await notch.compact(on: screen!)
            } else {
                await notch.transparent()
            }
            notch.moveToSky()
        case .closed:
            notchState = .closed
            await notch.close()
            guard let _ = NSScreen.selectedDisplay(.closed) else {
                await notch.transparent()
                return
            }
        case .transparent:
            if notchState != .closed {
                await setNotchState(.closed)
            }
            notchState = .transparent
            await notch.transparent()
        case .hidden:
            await notch.hide()
        }
    }
    
    public func showExtensionNotch(type: NotchContent, duration: Double) {
        guard self.notchContent != .locked || type == .unlocked else { return }
        guard type != .locked else { return }

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
                return
            }

            if notchState == .closed || notchState == .transparent {
                await setNotchState(.compact)
            }

            // Wait for display duration
            try? await Task.sleep(for: .seconds(duration))

            // Only the latest request should proceed past this point
            guard requestToken == self.extensionRequestCounter, !Task.isCancelled else {
                self.extensionNotchTask = nil
                return
            }

            if MusicManager.shared.music.isPlaying {
                if HideManager.shared.isFullScreen {
                    await setNotchState(.closed)
                }
                setNotchContent(.music)
            } else {
                if notchState != .open {
                    await setNotchState(.closed)
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
