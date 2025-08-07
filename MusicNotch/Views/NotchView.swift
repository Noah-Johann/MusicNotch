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
            if notchContentManager.notchContent == .musicPlayer {
                AlbumArtView(sizeState: "closed")
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .extensionView {
                ExtensionViewLeading(extensionType: .battery)
                    .transition(.blurReplace)
            }
        }
    }
}

struct notchViewTrailing: View {
    @ObservedObject var notchContentManager = notchContentState.shared
    
    var body: some View {
        ZStack {
            if notchContentManager.notchContent == .musicPlayer {
                AudioSpectView()
                    .transition(.blurReplace)
            } else if notchContentManager.notchContent == .extensionView {
                ExtensionViewTrailing(extensionType: .battery)
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
    
    @Published var notchContent: NotchContentType = .musicPlayer
    
    enum NotchContentType {
        case musicPlayer
        case extensionView
    }
}


