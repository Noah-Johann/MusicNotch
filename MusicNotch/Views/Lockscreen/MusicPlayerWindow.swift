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
            contentRect: NSRect(x: 0, y: 0, width: (NSScreen.main?.frame.width ?? NSScreen.screens.first?.frame.width ?? 700), height: 190),
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
        
        self.contentView = NSHostingView(rootView: LockScreenWidgetView().moveToSky())
        
        if let screen = NSScreen.screens.first {
            let screenFrame = screen.visibleFrame

            self.setFrameOrigin(NSPoint(x: 0, y: (screenFrame.maxY / 5) + Defaults[.lockPosition]))
        } else {
            self.setFrameOrigin(NSPoint(x: 0, y: 200 + Defaults[.lockPosition]))
        }
    }
}
