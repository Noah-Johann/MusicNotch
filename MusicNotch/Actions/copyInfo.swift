//
//  copyInfo.swift
//  MusicNotch
//
//  Created by Noah Johann on 04.04.25.
//

import Cocoa

func copyInfo(text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
    //print("Copied to clipboard: \(text)")
}
