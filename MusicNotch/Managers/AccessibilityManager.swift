//
//  AccessibilityManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 27.11.25.
//

import Foundation
import AppKit

class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()
    
    @Published var isReduceMotion: Bool = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    
    init() {
        setupObservers()
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
    
    private func setupObservers() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isReduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        }
    }
}
