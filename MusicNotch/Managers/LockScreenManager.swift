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
            Task.detached { if Defaults[.lockSound] { playSound(sound: .lock) } }
            WindowManager.showLockScreenPlayer(sendFromLock: true)
            SpotifyManager.shared.updateInfo()
            if Defaults[.lockExtension] {
                NotchManager.shared.showExtensionNotch(type: .locked)
            }
        }
    }
    
    @objc private func screenUnlocked() {
        Task { @MainActor in
            Task.detached { if Defaults[.unlockSound] { playSound(sound: .unlock) } }
            WindowManager.hideLockScreen()
            if Defaults[.lockExtension] {
                NotchManager.shared.showExtensionNotch(type: .unlocked)
            }
        }
    }
    
}
