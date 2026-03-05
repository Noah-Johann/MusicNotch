//
//  ScreenHelper.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.02.26.
//

import AppKit

class ScreenHelper {
    init() {
        setupScreenChange()
    }
    
    @objc func screenChange() {
        Task {
//            await NotchManager.shared.setNotchState(.hidden, changeDisplay: true)
//            await NotchManager.shared.createNotch()
            await NotchManager.shared.setNotchState(.closed, changeDisplay: true)
            await MusicManager.shared.updateMusic()
        }
    }

    func setupScreenChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenChange), name: NSApplication.didChangeScreenParametersNotification, object: nil
        )
    }
}
