//
//  AudioSpectView.swift
//  MusicNotch
//
//  Created by Noah Johann on 23.04.25.
//

import SwiftUI

struct AudioSpectView: View {
    
    @ObservedObject var spotifyManager = SpotifyManager.shared
    
    var body: some View {
        Rectangle()
            .fill(Color(nsColor: spotifyManager.aveColor ?? .white).gradient)
            .frame(width: 35, alignment: .center)
            .mask {
                AudioSpectrumView(isPlaying: $spotifyManager.isPlaying)
                    .frame(width: 15, height: 16)
            }
    }
}

#Preview {
    AudioSpectView()
}
