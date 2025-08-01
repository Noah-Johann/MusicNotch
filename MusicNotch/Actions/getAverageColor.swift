//
//  getAverageColor.swift
//  MusicNotch
//
//  Created by Noah Johann on 01.08.25.
//

import Foundation
import SwiftUI

func getAverageColor(image: NSImage, completion: @Sendable @escaping (NSColor?) -> Void) {
    image.averageColor { @Sendable color in
        Task { @MainActor in
            if let color = color {
                completion(color)
            } else {
                print("Failed to get average color")
                completion(nil)
            }
        }
    }
}
