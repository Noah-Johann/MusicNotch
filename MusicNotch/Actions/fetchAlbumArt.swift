//
//  fetchAlbumArt.swift
//  MusicNotch
//
//  Created by Noah Johann on 01.08.25.
//

import Foundation
import SwiftUI

func fetchAlbumArt(artURL: String, completion: @Sendable @escaping (NSImage?) -> Void) {
    guard let url = URL(string: artURL) else {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data, let image = NSImage(data: data) else {
            completion(nil)
            return
        }

        DispatchQueue.main.async {
            completion(image)
        }
    }.resume()
}
