//
//  Enums.swift
//  MusicNotch
//
//  Created by Noah Johann on 31.12.25.
//

import SwiftUI
import Defaults

enum Display: CaseIterable, Codable, Defaults.Serializable {
    case notchDisplay
    case mainDisplay
    
    var image: Image {
        switch self {
        case .notchDisplay: Image(systemName: "macbook")
                .resizable()
        case .mainDisplay: Image(systemName: "display.2")
                .resizable()
        }
    }
    
    var text: LocalizedStringKey {
        switch self {
        case .notchDisplay: "Notch display"
        case .mainDisplay: "Main display"
        }
    }
}
