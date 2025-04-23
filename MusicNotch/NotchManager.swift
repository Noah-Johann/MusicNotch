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
        notch.onHoverChanged = { isHovering in
            if isHovering {
                NotchManager.shared.setNotchContent("open", false)
            } else {
                NotchManager.shared.setNotchContent("closed", false)
            }
        }
    }
    
    public func changeNotch() {
        Task {
            if notchState == "closed" {
                SpotifyManager.shared.updateInfo()
                
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        print("No notch screen found")
                        await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                        return
                    }
                    await NotchManager.shared.notch.expand(on: notchScreen)
                    print("Show notch on: \(notchScreen)")
                } else {
                    await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                }
                
                notchState = "open"
            } else if notchState == "open" {
                SpotifyManager.shared.updateInfo()
                
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        print("No notch screen found")
                        await NotchManager.shared.notch.compact(on: NSScreen.screens.first!)
                        return
                    }
                    await NotchManager.shared.notch.compact(on: notchScreen)
                    print("Show notch on: \(notchScreen)")
                } else {
                    await NotchManager.shared.notch.compact(on: NSScreen.screens.first!)
                }
                
                notchState = "closed"
            } else if notchState == "hide" {
                SpotifyManager.shared.updateInfo()
                
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        print("No notch screen found")
                        await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                        return
                    }
                    await NotchManager.shared.notch.expand(on: notchScreen)
                    print("Show notch on: \(notchScreen)")
                } else {
                    await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                }
                
                notchState = "open"
            }
        }
    }
    
    public func setNotchContent(_ content: String, _ changeDisplay: Bool) {
        Task {
            if changeDisplay == true {
                await NotchManager.shared.notch.hide()
            }
            if content == "closed" {
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        print("No notch screen found")
                        await NotchManager.shared.notch.compact(on: NSScreen.screens.first!)
                        return
                    }
                    await NotchManager.shared.notch.compact(on: notchScreen)
                    print("Show notch on: \(notchScreen)")
                } else {
                    await NotchManager.shared.notch.compact(on: NSScreen.screens.first!)
                }
                
                SpotifyManager.shared.updateInfo()
                notchState = "closed"
            } else if content == "open" {
                if Defaults[.notchDisplay] == true {
                    guard let notchScreen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) else {
                        print("No notch screen found")
                        await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                        return
                    }
                    await NotchManager.shared.notch.expand(on: notchScreen)
                    print("Show notch on: \(notchScreen)")
                } else {
                    await NotchManager.shared.notch.expand(on: NSScreen.screens.first!)
                }
                
                SpotifyManager.shared.updateInfo()
                notchState = "open"
            } else if content == "hide" {
                await NotchManager.shared.notch.hide()
            }
        }
    }
    
}
