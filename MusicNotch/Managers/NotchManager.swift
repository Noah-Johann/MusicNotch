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
    static let shared = NotchManager()

    let notch: DynamicNotch<Player, AlbumArtView, AudioSpectView>
    private var openingTask: Task<Void, Never>?
    private var hapticTask: Task<Void, Never>?
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
            
            // Start new opening task
            self.openingTask = Task { @MainActor in
                // Wait for the opening delay
                do {
                    try await Task.sleep(nanoseconds: UInt64(Defaults[.openingDelay] * 1_000_000_000))
                } catch {
                    // Task was cancelled
                    return
                }
                
                // Double-check we're still hovering after the delay
                guard self.isCurrentlyHovering && !Task.isCancelled else {
                    return
                }
                
                // Open the notch
                self.setNotchContent("open", false)
                
                // Handle haptic feedback
                if Defaults[.hapticFeedback] && Defaults[.openingDelay] != 0 {
                    self.hapticTask = Task { @MainActor in
                        do {
                            try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
                        } catch {
                            return
                        }
                        
                        guard !Task.isCancelled else { return }
                        
                        let performer = NSHapticFeedbackManager.defaultPerformer
                        performer.perform(.alignment, performanceTime: .default)
                    }
                }
            }
        } else {
            // User stopped hovering
            // Cancel any pending opening operations
            self.openingTask?.cancel()
            self.hapticTask?.cancel()
            
            // If notch is not hidden, close it
            if notchState != "hide" {
                self.setNotchContent("closed", false)
            }
        }
        
        // Immediate haptic feedback for hover state change
        if Defaults[.hapticFeedback] {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
    
    public func changeNotch() {
        // Cancel any pending opening tasks when manually changing notch
        openingTask?.cancel()
        hapticTask?.cancel()
        
        Task {
            if notchState == "closed" {
                notchState = "open"
                SpotifyManager.shared.updateInfo()
                
                setNotchContent("open", false)
                
            
            } else if notchState == "open" {
                notchState = "closed"
                SpotifyManager.shared.updateInfo()
                
                setNotchContent("closed", false)
                
              
            } else if notchState == "hide" {
                notchState = "open"
                SpotifyManager.shared.updateInfo()
                
                setNotchContent("hide", false)
            }
        }
    }
    
    public func setNotchContent(_ content: String, _ changeDisplay: Bool) {
        Task {
            if changeDisplay == true {
                await NotchManager.shared.notch.hide()
            }
            if content == "closed" {
                notchState = "closed"
                SpotifyManager.shared.updateInfo()
                
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        print("No notch screen found")
                        await NotchManager.shared.notch.compact(on: NSScreen.screens.first!)
                        return
                    }
                    await NotchManager.shared.notch.compact(on: notchScreen)
                } else {
                    await NotchManager.shared.notch.compact(on: NSScreen.screens.first!)
                }
               
            } else if content == "open" {
                // Double-check we should still open (in case user stopped hovering)
                guard self.isCurrentlyHovering || notchState == "open" else {
                    // User stopped hovering, force compact instead
                    self.setNotchContent("closed", false)
                    return
                }
                
                notchState = "open"
                SpotifyManager.shared.updateInfo()

                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        print("No notch screen found")
                        await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                        return
                    }
                    await NotchManager.shared.notch.expand(on: notchScreen)
                } else {
                    await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                }
                
            } else if content == "hide" {
                if Defaults[.mainDisplay] == true && Defaults[.disableNotchOnHide] == true {
                    await NotchManager.shared.notch.hide()
                } else {
                    await NotchManager.shared.notch.close()
                }
            }
        }
    }
}
