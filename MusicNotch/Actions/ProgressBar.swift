//
//  ProgressBar.swift
//  MusicNotch
//
//  Created by Noah Johann on 16.03.25.
//

import Foundation
import ScriptingBridge
import AppKit
import SwiftUICore

func formatTime(_ seconds: Int) -> String {
    // Calculate hours, minutes, and remaining seconds
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    
    // Format based on whether hours exist
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    } else {
        return String(format: "%02d:%02d", minutes, secs)
    }
}







