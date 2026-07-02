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
    
    // Source: https://stackoverflow.com/a/79707276
    public func CheckForFullScreen() -> Bool {
        guard let windows = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) else {
            return false
        }

        var dockCount = 0
        for window in windows as NSArray
        {
            guard let winInfo = window as? NSDictionary else { continue }
            if winInfo["kCGWindowOwnerName"] as? String == "Dock"
            {
                let windowLayer = winInfo["kCGWindowLayer"]
                if let layerValue = windowLayer as? Int64, layerValue < 0 {
                    dockCount += 1
                    if dockCount > 1 {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
