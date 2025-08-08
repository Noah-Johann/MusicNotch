//
//  notchView.swift
//  MusicNotch
//
//  Created by Noah Johann on 07.08.25.
//

import SwiftUI

struct notchViewLeading: View {
    @ObservedObject var notchContentManager = notchContentState.shared
    
    var body: some View {
        ZStack {
            if notchContentManager.notchContent == .music {
                AlbumArtView(sizeState: "closed")
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .battery{
                ExtensionBatteryViewLeading()
                    .transition(.blurReplace)
            }
        }
    }
}

struct notchViewTrailing: View {
    @ObservedObject var notchContentManager = notchContentState.shared
    
    var body: some View {
        ZStack {
            if notchContentManager.notchContent == .music {
                AudioSpectView()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .battery {
                ExtensionBatteryViewTrailing()
                    .transition(.blurReplace)
            }
        }
    }
}

//#Preview {
//    notchViewLeading()
//}

class notchContentState: ObservableObject {
    static let shared = notchContentState()
    
    @Published var notchContent: NotchContent = .music
    
}


