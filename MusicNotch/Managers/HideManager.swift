//
//  HideManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 02.07.26.
//

import AppKit
import Defaults

class HideManager {
    static let shared = HideManager()
    
    var isFullScreen: Bool = false
    
    init() {
        setupObserver()
    }
    
    private func setupObserver() {
        print("setup Observer")
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            Task { @MainActor in
                await self.handleSpaceChange()
            }
        }
    }
    
    @MainActor
    private func handleSpaceChange() async {
        guard Defaults[.hideInFullScreen] == true else { return }
        isFullScreen = CheckForFullScreen()
        if isFullScreen == true && MusicManager.shared.music.isPlaying {
            switch NotchManager.shared.notchState {
                case .open, .compact:
                        print("close notch")
                        await NotchManager.shared.setNotchState(.closed)
                default: break
            }
        } else if isFullScreen == false && MusicManager.shared.music.isPlaying {
            switch NotchManager.shared.notchState {
                case .closed, .transparent:
                        await NotchManager.shared.setNotchState(.compact)
                default: break
            }
        }
    }
    
    // Source: https://stackoverflow.com/a/79922931
    func CheckForFullScreen() -> Bool {
       guard
         let windows = CGWindowListCopyWindowInfo(
           .optionOnScreenOnly,
           kCGNullWindowID
         ) as? [[String: Any]]
       else {
         return false
       }
       guard let screen = NSScreen.main?.frame else {
         return false
       }
       for window in windows {
         guard
           let windowBounds = maybeCast(
             window["kCGWindowBounds"],
             to: CFDictionary.self
           )
         else { continue }
         let bounds = CGRect(dictionaryRepresentation: windowBounds)
         let height = bounds?.size.height ?? 0
         let width = bounds?.size.width ?? 0
         if window["kCGWindowOwnerName"] as? String == "Dock"
           && window["kCGWindowLayer"] as? Int64 == -2_147_483_622
           && height == screen.height && width == screen.width
         {
           return true
         }
       }
       return false
     }
}

protocol CFTypeProtocol {
  static var typeID: CFTypeID { get }
}
func maybeCast<T, U: CFTypeProtocol>(_ value: T, to cfType: U.Type) -> U? {
  guard CFGetTypeID(value as CFTypeRef) == cfType.typeID else {
    return nil
  }
  return (value as! U)
}
extension CFDictionary: CFTypeProtocol {
  static var typeID: CFTypeID { return CFDictionaryGetTypeID() }
}
