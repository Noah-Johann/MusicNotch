//
//  ExtensionView.swift
//  MusicNotch
//
//  Created by Noah Johann on 03.08.25.
//

import SwiftUI

enum ExtensionType {
    case battery
}

struct ExtensionViewLeading: View {
    let extensionType: ExtensionType
    
    init(extensionType: ExtensionType) {
        self.extensionType = extensionType
    }
    
    var body: some View {
        switch extensionType {
        case .battery:
            ExtensionBatteryViewLeading()
        }
    }
}

struct ExtensionViewTrailing: View {
    let extensionType: ExtensionType
    
    init(extensionType: ExtensionType) {
        self.extensionType = extensionType
    }
    
    var body: some View {
        switch extensionType {
        case .battery:
            ExtensionBatteryViewTrailing()
        }
    }
}

//#Preview {
//    ExtensionView()
//}
