//
//  LockScreenManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 26.09.25.
//

import Foundation
import Defaults

class LockScreenManager: ObservableObject {
    static let shared = LockScreenManager()
    
    init() {
        setupObservers()
    }
    
    deinit {
        DistributedNotificationCenter.default.removeObserver(self)
    }
    
    private func setupObservers() {
        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil, queue: nil
        ) { _ in
            self.screenLocked()
        }

        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil, queue: nil
        ) { _ in
            self.screenUnlocked()
        }
    }
    
    @objc private func screenLocked() {
        Task { @MainActor in
            WindowManager.showLockScreen()
            SpotifyManager.shared.updateInfo()
            guard Defaults[.lockExtension] == true else { return }
            NotchManager.shared.showExtensionNotch(type: .locked)
        }
    }
    
    @objc private func screenUnlocked() {
        Task { @MainActor in
            WindowManager.hideLockScreen()
            guard Defaults[.lockExtension] == true else { return }
            NotchManager.shared.showExtensionNotch(type: .unlocked)
        }
    }
    
}
