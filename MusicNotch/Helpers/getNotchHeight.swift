//
//  getNotchHeight.swift
//  MusicNotch
//
//  Created by Noah Johann on 28.03.25.
//

import AppKit
import SwiftUI

var notchHeight: CGFloat = 40

func getNotchHeight () -> CGFloat {
    if let screenWithNotch = NSScreen.screens.first(where: { $0.frame.origin.y != 0 }) {
        let menuBarHeight = screenWithNotch.frame.height - screenWithNotch.visibleFrame.height
        print("Menu bar height (with notch): \(menuBarHeight) pixels")
        return menuBarHeight
    } else {
        print("no notch screen found")
        return 40
    }
}

func callNotchHeight() {
    notchHeight = getNotchHeight()
}
