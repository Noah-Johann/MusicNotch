//
//  MusicPlayerWindow.swift
//  MusicNotch
//
//  Created by Noah Johann on 24.09.26.
//

import AppKit
import Defaults
import SwiftUI

class MusicPlayerWindow: NSPanel {
    override var canBecomeKey: Bool {
        true
    }
    
    override var canBecomeMain: Bool {
        true
    }
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: 190),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.backgroundColor = .clear
        self.hasShadow = false
        
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        self.isFloatingPanel = true
        
        self.contentView = NSHostingView(rootView: LockScreenPlayingView().moveToSky())
        
        if let screen = NSScreen.screens.first {
            let screenFrame = screen.visibleFrame

            self.setFrameOrigin(NSPoint(x: (screenFrame.maxX / 2) - 175, y: (screenFrame.maxY / 6) + Defaults[.lockPosition]))
        } else {
            self.setFrameOrigin(NSPoint(x: 500, y: 200 + Defaults[.lockPosition]))
        }
    }
}
