//
//  keyListener.swift
//  MusicNotch
//
//  Created by Noah Johann on 27.03.25.
//

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleNotch = Self("toggleNotch", default: .init(.k, modifiers: [.command, .option]))
}
