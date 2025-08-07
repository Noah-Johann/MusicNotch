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

@MainActor
final class NotchManager {
    enum NotchState {
        case open
        case openWithoutHover
        case closed
        case hidden
    }
    
    @Published var notchState: NotchState = .hidden
    
    static let shared = NotchManager()
    
    let notch: DynamicNotch<Player, AlbumArtView, AudioSpectView>
    var extensionNotch: DynamicNotch<AnyView, ExtensionViewLeading, ExtensionViewTrailing>?
    
    private var openingTask: Task<Void, Never>?
    private var hapticTask: Task<Void, Never>?
    private var expandTask: Task<Void, Never>?
    private var isCurrentlyHovering = false
    
    private init() {
        notch = DynamicNotch(
            hoverBehavior: .increaseShadow,
            style: .notch,
            expanded: {
                Player()
            },
            compactLeading: {
                AlbumArtView(sizeState: "closed")
            },
            compactTrailing: {
                AudioSpectView()
            }
        )
        

        
        notch.onHoverChanged = { [weak self] isHovering in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.handleHoverChange(isHovering)
            }
        }
    }
    
    private func handleHoverChange(_ isHovering: Bool) {
        guard Defaults[.openNotchOnHover] else { return }
        
        self.isCurrentlyHovering = isHovering
        
        if isHovering {
            // Cancel any existing tasks
            self.openingTask?.cancel()
            self.hapticTask?.cancel()
            
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
                
                self.setNotchContent(.open, false)
                
                if Defaults[.hapticFeedback] && Defaults[.openingDelay] != 0 {
                    self.hapticTask = Task { @MainActor in
                        do {
                            try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
                        } catch {
                            return
                        }
                        
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
                self.setNotchContent(.closed, false)
            }
        }
        
        if Defaults[.hapticFeedback] {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
    
    public func changeNotch() {
        openingTask?.cancel()
        hapticTask?.cancel()
        expandTask?.cancel()
        
        Task {
            if notchState == .closed {
                setNotchContent(.openWithoutHover, false)
                
            } else if notchState == .open {
                setNotchContent(.closed, false)
                
            } else if notchState == .hidden {
                setNotchContent(.openWithoutHover, false)
            }
        }
    }
    
    public func setNotchContent(_ content: NotchState, _ changeDisplay: Bool) {
        Task {
            SpotifyManager.shared.updateInfo()
            
            if changeDisplay == true {
                await self.notch.hide()
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
                        self.setNotchContent(.closed, false)
                        self.expandTask = nil
                        return
                    }
                    
                    if Defaults[.notchDisplay] == true {
                        guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                            if Defaults[.noNotchScreenHide] {
                                await self.notch.hide()
                            } else {
                                await self.notch.expand(on: NSScreen.screens.first!)
                            }
                            return
                        }
                        await self.notch.expand(on: notchScreen)
                    } else {
                        await self.notch.expand(on: NSScreen.screens.first!)
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
                            } else {
                                await self.notch.expand(on: NSScreen.screens.first!)
                            }
                            return
                        }
                        await self.notch.expand(on: notchScreen)
                    } else {
                        await self.notch.expand(on: NSScreen.screens.first!)
                    }
                    
                    // Clear the task reference when completed
                    self.expandTask = nil
                }
                
            case .closed:
                notchState = .closed
                
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        if Defaults[.noNotchScreenHide] && Defaults[.notchDisplay] {
                            await self.notch.hide()
                        } else {
                            await self.notch.compact(on: NSScreen.screens.first!)
                        }
                        return
                    }
                    await self.notch.compact(on: notchScreen)
                } else {
                    await self.notch.compact(on: NSScreen.screens.first!)
                }
                
            case .hidden:
                notchState = .hidden
                if Defaults[.mainDisplay] == true && Defaults[.disableNotchOnHide] == true {
                    await self.notch.hide()
                } else if Defaults[.mainDisplay] == true && Defaults[.disableNotchOnHide] == false {
                    await self.notch.compact(on: NSScreen.screens.first!)
                }
                
                if Defaults[.notchDisplay] == true {
                    guard NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) != nil else {
                        if Defaults[.noNotchScreenHide] {
                            await self.notch.hide()
                        } else {
                            await self.notch.close()
                        }
                        return
                    }
                    await self.notch.close()
                }
            }
        }
    }
    
    public func showExtensionNotch(type: ExtensionType) {
        Task {
            print("show extensionNotch")
            if self.extensionNotch != nil {
                await self.extensionNotch?.hide()
                
                self.extensionNotch = nil
            }
 
            let lastNotchState = notchState
            
            let screen = NSScreen.main?.displayToUse
            
            guard screen != nil else { return }
            
            
            extensionNotch = DynamicNotch(style: .notch,
                                          expanded: { AnyView(EmptyView()) },
                                          compactLeading: { ExtensionViewLeading(extensionType: type) },
                                          compactTrailing: { ExtensionViewTrailing(extensionType: type) }
            )
                        
            await self.extensionNotch!.compact(on: screen!)
            
            await self.notch.hide()
            
            do {
                try await Task.sleep(nanoseconds: 3 * 1000000000)
            } catch {
                print("Error sleeping")
            }
            
            await self.extensionNotch?.close()
            
            
            if lastNotchState == .hidden {
                setNotchContent(.hidden, false)
            } else {
                setNotchContent(.closed, false)
            }
            
            await self.extensionNotch?.close()
            
            await self.extensionNotch?.hide()
            
            extensionNotch = nil
        }
    }
}
