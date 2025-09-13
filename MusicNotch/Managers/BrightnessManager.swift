//
//  BrightnessManager.swift
//  MusicNotch
//
//  Created by Noah Johann on 13.09.25.
//

import Foundation

class BrightnessManager: ObservableObject {
    static let shared = BrightnessManager()
    
    @Published var brightness: CGFloat = 0
    
    
}
