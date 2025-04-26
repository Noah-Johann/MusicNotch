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
        var isStillHovering = false

        notch.onHoverChanged = { isHovering in
            if Defaults[.openNotchOnHover] {
                isStillHovering = isHovering

                if isHovering {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Defaults[.openingDelay]) {
                        if isStillHovering {
                            NotchManager.shared.setNotchContent("open", false)
                        }
                    }
                } else {
                    NotchManager.shared.setNotchContent("closed", false)
                }
            }
        }
    }
    
    public func changeNotch() {
        Task {
            if notchState == "closed" {
                notchState = "open"
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
                
            
            } else if notchState == "open" {
                notchState = "closed"
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
                
              
            } else if notchState == "hide" {
                notchState = "open"
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
                    print("Show notch on: \(notchScreen)")
                } else {
                    await NotchManager.shared.notch.compact(on: NSScreen.screens.first!)
                }
               
            } else if content == "open" {
                notchState = "open"
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
                
            } else if content == "hide" {
                await NotchManager.shared.notch.hide()
            }
        }
    }
    
}
