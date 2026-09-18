//
//  GlassView.swift
//  MusicNotch
//
//  Created by Noah Johann on 18.09.26.
//

import AppKit
import SwiftUI

@available(macOS 26.0, *)
struct GlassView: NSViewRepresentable {
    let style: NSGlassEffectView.Style
    let cornerRadius: CGFloat
    
    func makeNSView(context _: Context) -> NSGlassEffectView {
        let glassView = NSGlassEffectView()
        glassView.style = style
        glassView.cornerRadius = cornerRadius
        if #available(macOS 27.0, *) {
            glassView.effectIsInteractive = false
        } else {}
        return glassView
    }
    
    func updateNSView(_ nsView: NSGlassEffectView, context: Context) {}
}
