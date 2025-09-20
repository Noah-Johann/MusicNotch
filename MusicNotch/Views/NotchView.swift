//
//  notchView.swift
//  MusicNotch
//
//  Created by Noah Johann on 07.08.25.
//

import SwiftUI

struct NotchViewLeading: View {
    @ObservedObject var notchContentManager = NotchContentState.shared
    
    var body: some View {
        ZStack {
            if notchContentManager.notchContent == .music {
                AlbumArtView(sizeState: "closed")
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .battery {
                ExtensionBatteryViewLeading()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .volume {
                ExtensionHUDViewLeading(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .brightness {
                 ExtensionHUDViewLeading(hudType: .brightness)
                    .transition(.blurReplace)
            }
        }
    }
}

struct NotchViewTrailing: View {
    @ObservedObject var notchContentManager = NotchContentState.shared
    
    var body: some View {
        ZStack {
            if notchContentManager.notchContent == .music {
                AudioSpectView()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .battery {
                ExtensionBatteryViewTrailing()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .volume {
                ExtensionHUDViewTrailing(hudType: .volume)
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .brightness {
                ExtensionHUDViewTrailing(hudType: .brightness)
                    .transition(.blurReplace)
            }
        }
    }
}


class NotchContentState: ObservableObject {
    static let shared = NotchContentState()
    
    @Published var notchContent: NotchContent = .music
    
}


